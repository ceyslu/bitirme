import Foundation

final class PanolarService {
    static let shared = PanolarService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchDashboardData(filtre: PanoFiltre) async throws -> PanoOzet {
        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Aktif kullanıcı bulunamadı."
            ])
        }

        async let jobsTask = fetchJobs(userId: userId)
        async let fuelTask = FuelExpenseService.shared.fetchFuelExpenses(userId: userId)
        async let maintenanceTask = BakimGideriService.shared.fetchMaintenanceExpenses(userId: userId)

        let jobs = try await jobsTask
        let fuelExpenses = try await fuelTask
        let maintenanceExpenses = try await maintenanceTask

        let mergedExpenses = buildExpenseRows(
            fuelExpenses: fuelExpenses,
            maintenanceExpenses: maintenanceExpenses
        )

        let filteredJobs = filterJobs(jobs, by: filtre)
        let filteredExpenses = filterExpenses(mergedExpenses, by: filtre)

        let gelirKayitlari = filteredJobs
            .filter { $0.paidAmount > 0 }
            .sorted { parseDate($0.jobDate) > parseDate($1.jobDate) }
            .map { job in
                PanoGelirSatiri(
                    id: job.id,
                    sirketAdi: job.customerName ?? "Şirket Yok",
                    isTuru: job.jobTypeName ?? "İş Türü Yok",
                    alinanTutar: job.paidAmount,
                    isToplami: job.totalPrice,
                    tarih: parseDate(job.jobDate),
                    odemeAciklamasi: odemeAciklamasi(
                        paidAmount: job.paidAmount,
                        totalPrice: job.totalPrice
                    )
                )
            }

        let toplamGelir = gelirKayitlari.reduce(0) { $0 + $1.alinanTutar }
        let toplamGider = filteredExpenses.reduce(0) { $0 + $1.tutar }
        let netKar = toplamGelir - toplamGider
        let bekleyenOdemeTutari = filteredJobs.reduce(0) { toplam, job in
            toplam + max(job.totalPrice - job.paidAmount, 0)
        }

        let grafik = buildChart(
            jobs: filteredJobs,
            expenses: filteredExpenses,
            filtre: filtre
        )

        let gelirIslemleri = gelirKayitlari.prefix(4).map {
            PanoSonIslem(
                id: "income-\($0.id)",
                tur: "Gelir",
                baslik: $0.sirketAdi,
                altBaslik: $0.isTuru,
                tutar: $0.alinanTutar,
                tarih: $0.tarih
            )
        }

        let giderIslemleri = filteredExpenses.prefix(4).map {
            PanoSonIslem(
                id: "expense-\($0.id)",
                tur: $0.tur,
                baslik: $0.baslik,
                altBaslik: $0.altBaslik,
                tutar: $0.tutar,
                tarih: $0.tarih
            )
        }

        let sonIslemler = (gelirIslemleri + giderIslemleri)
            .sorted { $0.tarih > $1.tarih }

        return PanoOzet(
            toplamGelir: toplamGelir,
            toplamGider: toplamGider,
            netKar: netKar,
            bekleyenOdemeTutari: bekleyenOdemeTutari,
            grafik: grafik,
            gelirKayitlari: gelirKayitlari,
            giderKayitlari: filteredExpenses,
            sonIslemler: sonIslemler
        )
    }

    private func fetchJobs(userId: Int) async throws -> [PanoIsKaydi] {
        guard let url = URL(string: "\(baseURL)/api/jobs?userId=\(userId)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "İş kayıtları alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([PanoIsKaydi].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "İş kayıtları alınamadı"
            ])
        }
    }

    private func buildExpenseRows(
        fuelExpenses: [YakitGideri],
        maintenanceExpenses: [BakimGideri]
    ) -> [PanoGiderSatiri] {
        let fuelRows = fuelExpenses.map { gider in
            PanoGiderSatiri(
                id: "fuel-\(gider.id)",
                tur: "Mazot",
                baslik: "MAZOT ALIMI",
                altBaslik: gider.makineAdi ?? "-",
                tutar: gider.tutar,
                tarih: parseDate(gider.giderTarihi)
            )
        }

        let maintenanceRows = maintenanceExpenses.map { gider in
            PanoGiderSatiri(
                id: "maintenance-\(gider.id)",
                tur: "Bakım",
                baslik: gider.islemAdi.uppercased(),
                altBaslik: gider.makineAdi ?? "-",
                tutar: gider.tutar,
                tarih: parseDate(gider.giderTarihi)
            )
        }

        return (fuelRows + maintenanceRows).sorted { $0.tarih > $1.tarih }
    }

    private func filterJobs(_ jobs: [PanoIsKaydi], by filtre: PanoFiltre) -> [PanoIsKaydi] {
        let calendar = Calendar.current
        let now = Date()

        switch filtre {
        case .haftalik:
            let start = calendar.date(byAdding: .day, value: -6, to: now) ?? now
            return jobs.filter { parseDate($0.jobDate) >= start }

        case .aylik:
            let start = calendar.date(byAdding: .month, value: -11, to: now) ?? now
            return jobs.filter { parseDate($0.jobDate) >= start }
        }
    }

    private func filterExpenses(_ expenses: [PanoGiderSatiri], by filtre: PanoFiltre) -> [PanoGiderSatiri] {
        let calendar = Calendar.current
        let now = Date()

        switch filtre {
        case .haftalik:
            let start = calendar.date(byAdding: .day, value: -6, to: now) ?? now
            return expenses.filter { $0.tarih >= start }

        case .aylik:
            let start = calendar.date(byAdding: .month, value: -11, to: now) ?? now
            return expenses.filter { $0.tarih >= start }
        }
    }

    private func buildChart(
        jobs: [PanoIsKaydi],
        expenses: [PanoGiderSatiri],
        filtre: PanoFiltre
    ) -> [PanoGrafikNoktasi] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")

        switch filtre {
        case .haftalik:
            formatter.dateFormat = "E"

            let days = (0..<7).compactMap {
                calendar.date(byAdding: .day, value: -6 + $0, to: Date())
            }

            return days.map { day in
                let gelir = jobs
                    .filter { calendar.isDate(parseDate($0.jobDate), inSameDayAs: day) }
                    .reduce(0) { $0 + $1.paidAmount }

                let gider = expenses
                    .filter { calendar.isDate($0.tarih, inSameDayAs: day) }
                    .reduce(0) { $0 + $1.tutar }

                return PanoGrafikNoktasi(
                    baslik: formatter.string(from: day).uppercased(),
                    gelir: gelir,
                    gider: gider
                )
            }

        case .aylik:
            formatter.dateFormat = "MMM"

            let months = (0..<12).compactMap {
                calendar.date(byAdding: .month, value: -11 + $0, to: Date())
            }

            return months.map { month in
                let gelir = jobs
                    .filter {
                        calendar.isDate(parseDate($0.jobDate), equalTo: month, toGranularity: .month)
                    }
                    .reduce(0) { $0 + $1.paidAmount }

                let gider = expenses
                    .filter {
                        calendar.isDate($0.tarih, equalTo: month, toGranularity: .month)
                    }
                    .reduce(0) { $0 + $1.tutar }

                return PanoGrafikNoktasi(
                    baslik: formatter.string(from: month).uppercased(),
                    gelir: gelir,
                    gider: gider
                )
            }
        }
    }

    private func odemeAciklamasi(paidAmount: Double, totalPrice: Double) -> String {
        if paidAmount >= totalPrice, totalPrice > 0 {
            return "Tam ödeme alındı"
        } else {
            return "Kısmi ödeme alındı"
        }
    }

    private func parseDate(_ text: String) -> Date {
        let isoFormatter1 = ISO8601DateFormatter()
        isoFormatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter1.date(from: text) {
            return date
        }

        let isoFormatter2 = ISO8601DateFormatter()
        isoFormatter2.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter2.date(from: text) {
            return date
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"

        if let date = fallbackFormatter.date(from: text) {
            return date
        }

        return .distantPast
    }
}

