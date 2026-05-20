////
//  MakineDuzenleView.swift
//  Santiyem
//

import SwiftUI

struct MakineDuzenleView: View {
    let makine: Makine
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var seciliSekme: Sekme = .duzenle

    @State private var makineAdi: String
    @State private var saatlikUcret: String
    @State private var aktifMi: Bool

    @State private var yakitGiderleri: [YakitGideri] = []
    @State private var bakimGiderleri: [BakimGideri] = []

    @State private var mazotEkleAcik = false
    @State private var bakimEkleAcik = false

    @State private var yukleniyor = false
    @State private var kaydediliyor = false
    @State private var mesaj = ""

    enum Sekme {
        case duzenle
        case gider
    }

    struct GiderSatiri: Identifiable {
        let id: String
        let tur: String
        let baslik: String
        let altBaslik: String
        let tutar: Double
        let tarihMetni: String
    }

    init(makine: Makine, onSaved: (() -> Void)? = nil) {
        self.makine = makine
        self.onSaved = onSaved
        _makineAdi = State(initialValue: makine.ad)
        _saatlikUcret = State(initialValue: String(Int(makine.saatlikUcret)))
        _aktifMi = State(initialValue: makine.aktifMi)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        ustAlan
                        sekmeSecici

                        if seciliSekme == .duzenle {
                            duzenleAlani
                        } else {
                            giderAlani
                        }

                        if !mesaj.isEmpty {
                            Text(mesaj)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarBackButtonHidden(true)
            .task {
                await giderleriYukle()
            }
            .sheet(isPresented: $mazotEkleAcik) {
                GiderEkleView(
                    makineId: makine.id,
                    onSaved: {
                        Task {
                            await giderleriYukle()
                        }
                    }
                )
            }
            .sheet(isPresented: $bakimEkleAcik) {
                BakimEkleView(
                    makineId: makine.id,
                    onSaved: {
                        Task {
                            await giderleriYukle()
                        }
                    }
                )
            }
        }
    }

    private var ustAlan: some View {
        HStack(spacing: 16) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white)
                        .frame(width: 54, height: 54)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                }
            }

            Spacer()

            Text("MAKİNE\nYÖNETİMİ")
                .font(.system(size: 27, weight: .heavy))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

            Spacer()

            Color.clear
                .frame(width: 54, height: 54)
        }
        .padding(.top, 8)
    }

    private var sekmeSecici: some View {
        HStack(spacing: 0) {
            sekmeButonu("DÜZENLE", sekme: .duzenle)
            sekmeButonu("MAZOT & BAKIM", sekme: .gider)
        }
        .padding(5)
        .background(Color.white.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
    }

    private func sekmeButonu(_ text: String, sekme: Sekme) -> some View {
        Button {
            seciliSekme = sekme
        } label: {
            Text(text)
                .font(.system(size: 16, weight: .heavy))
                .tracking(1.1)
                .foregroundColor(
                    seciliSekme == sekme
                    ? (sekme == .gider ? .orange : Color(red: 35/255, green: 47/255, blue: 74/255))
                    : .gray.opacity(0.7)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(seciliSekme == sekme ? Color.white : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var duzenleAlani: some View {
        VStack(alignment: .leading, spacing: 20) {
            alanBaslik("MAKİNE ADI")
            normalAlan(text: $makineAdi)

            alanBaslik("SAATLİK ÜCRET (₺)")
            normalAlan(text: $saatlikUcret, keyboardType: .decimalPad)

            HStack {
                Text("Makine Aktif")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                Spacer()

                Toggle("", isOn: $aktifMi)
                    .labelsHidden()
                    .tint(.green)
            }
            .padding(.horizontal, 22)
            .frame(height: 84)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )

            Button {
                Task {
                    await kaydetMakine()
                }
            } label: {
                Text(kaydediliyor ? "KAYDEDİLİYOR..." : "DEĞİŞİKLİKLERİ KAYDET")
                    .font(.system(size: 21, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 76)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.orange.opacity(0.18), radius: 10, x: 0, y: 6)
            }
        }
    }

    private var giderAlani: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AYLIK TOPLAM GİDER")
                            .font(.system(size: 14, weight: .heavy))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.88))

                        Text("\(aylikToplamGider.formatted(.number.precision(.fractionLength(0...2)))) ₺")
                            .font(.system(size: 32, weight: .heavy))
                            .italic()
                            .foregroundColor(.white)
                    }

                    Spacer()
                }

                HStack(spacing: 10) {
                    Button {
                        mazotEkleAcik = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))

                            Text("MAZOT EKLE")
                                .font(.system(size: 15, weight: .heavy))
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    Button {
                        bakimEkleAcik = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "wrench.and.screwdriver")
                                .font(.system(size: 15, weight: .bold))

                            Text("BAKIM EKLE")
                                .font(.system(size: 15, weight: .heavy))
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.orange.opacity(0.20), radius: 12, x: 0, y: 8)

            Text("GİDER TIMELINE")
                .font(.system(size: 16, weight: .heavy))
                .italic()
                .tracking(2)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.horizontal, 4)

            VStack(spacing: 14) {
                if tumGiderler.isEmpty {
                    Text("Henüz mazot veya bakım kaydı yok.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 30)
                } else {
                    ForEach(tumGiderler) { gider in
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(gider.tur == "bakim" ? Color.blue.opacity(0.08) : Color.orange.opacity(0.08))
                                    .frame(width: 68, height: 68)

                                Image(systemName: gider.tur == "bakim" ? "wrench.and.screwdriver" : "drop")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(gider.tur == "bakim" ? .blue : .orange)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(gider.baslik)
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                                Text(gider.altBaslik)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.8))
                            }

                            Spacer()

                            Text("-\(gider.tutar.formatted(.number.precision(.fractionLength(0...2)))) ₺")
                                .font(.system(size: 22, weight: .heavy))
                                .italic()
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                    }
                }
            }
        }
    }

    private func alanBaslik(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .heavy))
            .tracking(2)
            .foregroundColor(.gray.opacity(0.8))
    }

    private func normalAlan(text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        TextField("", text: text)
            .keyboardType(keyboardType)
            .font(.system(size: 22, weight: .heavy))
            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
            .padding(.horizontal, 22)
            .frame(height: 84)
            .background(Color.white.opacity(0.75))
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private var makineyeAitYakitGiderleri: [YakitGideri] {
        yakitGiderleri.filter { $0.makineId == makine.id }
    }

    private var makineyeAitBakimGiderleri: [BakimGideri] {
        bakimGiderleri.filter { $0.makineId == makine.id }
    }

    private var aylikToplamGider: Double {
        makineyeAitYakitGiderleri.reduce(0) { $0 + $1.tutar }
        + makineyeAitBakimGiderleri.reduce(0) { $0 + $1.tutar }
    }

    private var tumGiderler: [GiderSatiri] {
        let yakitSatirlari = makineyeAitYakitGiderleri.map { gider in
            GiderSatiri(
                id: "fuel-\(gider.id)",
                tur: "mazot",
                baslik: "MAZOT ALIMI",
                altBaslik: formatTarih(gider.giderTarihi),
                tutar: gider.tutar,
                tarihMetni: gider.giderTarihi
            )
        }

        let bakimSatirlari = makineyeAitBakimGiderleri.map { gider in
            GiderSatiri(
                id: "maintenance-\(gider.id)",
                tur: "bakim",
                baslik: gider.islemAdi.uppercased(),
                altBaslik: formatTarih(gider.giderTarihi),
                tutar: gider.tutar,
                tarihMetni: gider.giderTarihi
            )
        }

        return (yakitSatirlari + bakimSatirlari).sorted {
            parseDate($0.tarihMetni) > parseDate($1.tarihMetni)
        }
    }

    @MainActor
    private func giderleriYukle() async {
        yukleniyor = true
        mesaj = ""

        defer { yukleniyor = false }

        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            mesaj = "Aktif kullanıcı bulunamadı."
            return
        }

        do {
            async let yakitTask = FuelExpenseService.shared.fetchFuelExpenses(userId: userId)
            
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                mesaj = "Aktif kullanıcı bulunamadı."
                return
            }

            async let bakimTask = BakimGideriService.shared.fetchMaintenanceExpenses(userId: userId)

            yakitGiderleri = try await yakitTask
            bakimGiderleri = try await bakimTask
        } catch {
            mesaj = error.localizedDescription
        }
    }

    @MainActor
    private func kaydetMakine() async {
        mesaj = ""

        let temizAd = makineAdi.trimmingCharacters(in: .whitespacesAndNewlines)
        let temizUcret = Double(saatlikUcret.replacingOccurrences(of: ",", with: ".")) ?? -1

        guard !temizAd.isEmpty else {
            mesaj = "Makine adı boş olamaz."
            return
        }

        guard temizUcret >= 0 else {
            mesaj = "Geçerli bir saatlik ücret girin."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                mesaj = "Aktif kullanıcı bulunamadı."
                return
            }
            _ = try await MachineService.shared.updateMachine(
                userId: userId,
                id: makine.id,
                name: temizAd,
                hourlyPrice: temizUcret,
                isActive: aktifMi
            )


            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }

    private func formatTarih(_ tarihMetni: String) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "tr_TR")
        displayFormatter.dateFormat = "dd.MM.yyyy"

        let isoFormatter1 = ISO8601DateFormatter()
        isoFormatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter1.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        let isoFormatter2 = ISO8601DateFormatter()
        isoFormatter2.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter2.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"

        if let date = fallbackFormatter.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        return tarihMetni
    }

    private func parseDate(_ tarihMetni: String) -> Date {
        let isoFormatter1 = ISO8601DateFormatter()
        isoFormatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter1.date(from: tarihMetni) {
            return date
        }

        let isoFormatter2 = ISO8601DateFormatter()
        isoFormatter2.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter2.date(from: tarihMetni) {
            return date
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"

        return fallbackFormatter.date(from: tarihMetni) ?? .distantPast
    }
}

#Preview {
    MakineDuzenleView(
        makine: Makine(
            id: 1,
            ad: "JSB",
            saatlikUcret: 3000,
            aktifMi: true,
            olusturulmaTarihi: nil
        )
    )
}

