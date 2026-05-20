import SwiftUI

struct MusteriIsEkleView: View {
    let musteriId: Int
    let musteriAdi: String
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var makineler: [Makine] = []
    @State private var isTurleri: [IsTuru] = []

    @State private var secilenMakineId: Int?
    @State private var secilenIsTuruId: Int?

    @State private var tarih = Date()
    @State private var saatMetni = "1"
    @State private var dakikaMetni = "0"
    @State private var yolUcreti = ""
    @State private var not = ""

    @State private var yukleniyor = false
    @State private var kaydediliyor = false
    @State private var mesaj = ""

    private var secilenMakine: Makine? {
        guard let secilenMakineId else { return nil }
        return makineler.first(where: { $0.id == secilenMakineId })
    }

    private var secilenIsTuru: IsTuru? {
        guard let secilenIsTuruId else { return nil }
        return isTurleri.first(where: { $0.id == secilenIsTuruId })
    }

    private var saatlikUcret: Double {
        secilenMakine?.saatlikUcret ?? 0
    }

    private var saatDegeri: Int {
        Int(saatMetni) ?? 0
    }

    private var dakikaDegeri: Int {
        Int(dakikaMetni) ?? 0
    }

    private var toplamSureSaat: Double {
        Double(saatDegeri) + (Double(dakikaDegeri) / 60.0)
    }

    private var yolUcretiDegeri: Double {
        Double(yolUcreti.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var hesaplananToplam: Double {
        (toplamSureSaat * saatlikUcret) + yolUcretiDegeri
    }

    private var sureGosterimi: String {
        if saatDegeri == 0 && dakikaDegeri == 0 {
            return "0 dk"
        }

        if dakikaDegeri == 0 {
            return "\(saatDegeri) saat"
        }

        if saatDegeri == 0 {
            return "\(dakikaDegeri) dk"
        }

        return "\(saatDegeri) saat \(dakikaDegeri) dk"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("YENİ İŞ BAŞLAT")
                            .font(.system(size: 32, weight: .heavy))
                            .italic()
                            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)

                        Text(musteriAdi.uppercased())
                            .font(.system(size: 15, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.orange)

                        baslikSatiri("İŞ TARİHİ", editable: true)
                        tarihAlani

                        baslikSatiri("HİZMET TÜRÜ", editable: true)
                        hizmetTuruAlani

                        baslikSatiri("MAKİNE SEÇİMİ", editable: true)
                        makineAlani

                        baslikSatiri("ÇALIŞMA SÜRESİ", editable: true)
                        sureAlani

                        baslikSatiri("YOL ÜCRETİ (OPS.)", editable: true)
                        yolUcretiAlani

                        toplamKart

                        baslikSatiri("NOT (OPSİYONEL)", editable: true)
                        TextField("İsteğe bağlı not", text: $not, axis: .vertical)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.75))
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        if !mesaj.isEmpty {
                            Text(mesaj)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        Button {
                            Task {
                                await kaydet()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 28, weight: .semibold))

                                Text(kaydediliyor ? "KAYDEDİLİYOR..." : "KAYDI TAMAMLA")
                                    .font(.system(size: 24, weight: .heavy))
                                    .italic()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .disabled(kaydediliyor || yukleniyor)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 30)
                }
            }
            .task {
                await verileriYukle()
            }
        }
    }

    private func baslikSatiri(_ text: String, editable: Bool) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 15, weight: .heavy))
                .tracking(2)
                .foregroundColor(.gray.opacity(0.85))

            Spacer()

            if editable {
                Text("DÜZENLE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
    }

    private var tarihAlani: some View {
        HStack {
            Image(systemName: "calendar")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.orange)

            DatePicker(
                "",
                selection: $tarih,
                displayedComponents: .date
            )
            .labelsHidden()
            .font(.system(size: 20, weight: .heavy))
            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

            Spacer()

            Image(systemName: "calendar")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black.opacity(0.85))
        }
        .padding(.horizontal, 20)
        .frame(height: 80)
        .background(Color.white.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }

    private var hizmetTuruAlani: some View {
        Menu {
            ForEach(isTurleri) { isTuru in
                Button(isTuru.ad) {
                    secilenIsTuruId = isTuru.id
                }
            }
        } label: {
            HStack {
                Text((secilenIsTuru?.ad ?? "HİZMET TÜRÜ SEÇ").uppercased())
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 80)
            .background(Color.white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }

    private var makineAlani: some View {
        Menu {
            ForEach(makineler.filter(\.aktifMi)) { makine in
                Button("\(makine.ad) (\(Int(makine.saatlikUcret)) ₺/s)") {
                    secilenMakineId = makine.id
                }
            }
        } label: {
            HStack {
                Text(
                    secilenMakine.map {
                        "\($0.ad.uppercased()) (\(Int($0.saatlikUcret)) ₺/s)"
                    } ?? "MAKİNE SEÇ"
                )
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(.orange)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .frame(height: 80)
            .background(Color.white.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
        .buttonStyle(.plain)
    }

    private var sureAlani: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "clock")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.gray.opacity(0.45))

                    TextField("Saat", text: $saatMetni)
                        .keyboardType(.numberPad)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                }
                .padding(.horizontal, 20)
                .frame(height: 78)
                .background(Color.white.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 24))

                HStack(spacing: 10) {
                    Image(systemName: "timer")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.orange)

                    TextField("Dakika", text: $dakikaMetni)
                        .keyboardType(.numberPad)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                }
                .padding(.horizontal, 20)
                .frame(height: 78)
                .background(Color.white.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            Text("Toplam süre: \(sureGosterimi)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray.opacity(0.75))
        }
    }

    private var yolUcretiAlani: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.circle")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.orange)

            TextField("0", text: $yolUcreti)
                .keyboardType(.decimalPad)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

            Text("₺")
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.horizontal, 20)
        .frame(height: 78)
        .background(Color.white.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var toplamKart: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("HESAPLANAN TOPLAM")
                    .font(.system(size: 15, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(Color.indigo.opacity(0.7))

                Text("\(hesaplananToplam.formatted(.number.precision(.fractionLength(0...2)))) ₺")
                    .font(.system(size: 34, weight: .heavy))
                    .italic()
                    .foregroundColor(Color.indigo)

                Text("Süre: \(sureGosterimi)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray.opacity(0.75))
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .frame(width: 74, height: 74)

                Image(systemName: "calculator")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color.indigo)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .background(Color.indigo.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.indigo.opacity(0.12), lineWidth: 1)
        )
    }

    @MainActor
    private func verileriYukle() async {
        yukleniyor = true
        mesaj = ""

        defer { yukleniyor = false }

        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            mesaj = "Aktif kullanıcı bulunamadı."
            return
        }

        do {
            async let makinelerTask = MachineService.shared.fetchMachines(userId: userId)
            async let isTurleriTask = JobTypeService.shared.fetchJobTypes(userId: userId)

            let gelenMakineler = try await makinelerTask
            let gelenIsTurleri = try await isTurleriTask

            makineler = gelenMakineler.filter { $0.aktifMi }
            isTurleri = gelenIsTurleri
        } catch {
            mesaj = error.localizedDescription
        }
    }

    @MainActor
    private func kaydet() async {
        mesaj = ""

        guard let secilenMakineId else {
            mesaj = "Lütfen makine seçin."
            return
        }

        guard let secilenIsTuruId else {
            mesaj = "Lütfen hizmet türü seçin."
            return
        }

        guard saatDegeri > 0 || dakikaDegeri > 0 else {
            mesaj = "Geçerli bir çalışma süresi girin."
            return
        }

        guard dakikaDegeri >= 0 && dakikaDegeri < 60 else {
            mesaj = "Dakika 0 ile 59 arasında olmalı."
            return
        }

        guard saatlikUcret > 0 else {
            mesaj = "Seçilen makinenin saatlik ücreti bulunamadı."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        do {
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                mesaj = "Aktif kullanıcı bulunamadı."
                return
            }

            try await JobService.shared.createJob(
                userId: userId,
                customerId: musteriId,
                machineId: secilenMakineId,
                jobTypeId: secilenIsTuruId,
                jobDate: formatter.string(from: tarih),
                durationHours: toplamSureSaat,
                hourlyPrice: saatlikUcret,
                roadFee: yolUcretiDegeri,
                totalPrice: hesaplananToplam,
                paymentStatus: "bekliyor",
                notes: not
            )


            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    MusteriIsEkleView(
        musteriId: 1,
        musteriAdi: "Ahmet Yılmaz"
    )
}

