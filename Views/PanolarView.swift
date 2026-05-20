import SwiftUI
import Charts

struct PanolarView: View {
    @StateObject private var oturum = OturumYonetici.shared

    @State private var seciliFiltre: PanoFiltre = .haftalik
    @State private var ozet: PanoOzet?
    @State private var yukleniyor = false
    @State private var hataMesaji = ""

    @State private var gelirSayfasiAcik = false
    @State private var giderSayfasiAcik = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        ustAlan

                        if yukleniyor {
                            ProgressView("Panolar yükleniyor...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else if !hataMesaji.isEmpty {
                            Text(hataMesaji)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.top, 50)
                        } else if let ozet {
                            filtreSecici
                            ozetAlan(ozet)
                            aksiyonButonlari
                            grafikAlan(ozet)
                            sonIslemlerAlani(ozet)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfilView()) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(profilHarf)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                )

                            Text("PROFİL")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                    }
                }
            }
            .fullScreenCover(isPresented: $gelirSayfasiAcik) {
                if let ozet {
                    GelirKayitlariView(kayitlar: ozet.gelirKayitlari)
                }
            }
            .fullScreenCover(isPresented: $giderSayfasiAcik) {
                if let ozet {
                    GiderKayitlariView(kayitlar: ozet.giderKayitlari)
                }
            }
            .task {
                await verileriYukle()
            }
            .onChange(of: seciliFiltre) { _, _ in
                Task {
                    await verileriYukle()
                }
            }
        }
    }

    private var profilHarf: String {
        guard let ad = oturum.aktifKullanici?.adSoyad,
              let ilk = ad.trimmingCharacters(in: .whitespacesAndNewlines).first else {
            return "?"
        }

        return String(ilk).uppercased()
    }

    private var ustAlan: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PANOLAR")
                .font(.system(size: 26, weight: .semibold))
                .italic()
                .foregroundColor(
                    Color(red: 30/255, green: 40/255, blue: 70/255)
                )

            Rectangle()
                .fill(Color.orange)
                .frame(width: 110, height: 3)

            if let kullanici = oturum.aktifKullanici {
                Text("\(kullanici.sirketAdi) • \(kullanici.telefon)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var filtreSecici: some View {
        HStack(spacing: 0) {
            ForEach(PanoFiltre.allCases) { filtre in
                Button {
                    seciliFiltre = filtre
                } label: {
                    Text(filtre.rawValue.uppercased())
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundColor(seciliFiltre == filtre ? .orange : .gray.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(seciliFiltre == filtre ? Color.white : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private func ozetAlan(_ ozet: PanoOzet) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ozetKart(
                    baslik: "TOPLAM GELİR",
                    metin: "\(Int(ozet.toplamGelir)) ₺",
                    renk: .green
                )

                ozetKart(
                    baslik: "TOPLAM GİDER",
                    metin: "\(Int(ozet.toplamGider)) ₺",
                    renk: .red
                )
            }

            HStack(spacing: 14) {
                ozetKart(
                    baslik: "NET KAR",
                    metin: "\(Int(ozet.netKar)) ₺",
                    renk: .indigo
                )

                ozetKart(
                    baslik: "BEKLEYEN ÖDEME",
                    metin: "\(Int(ozet.bekleyenOdemeTutari)) ₺",
                    renk: Color.orange
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private func ozetKart(baslik: String, metin: String, renk: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(baslik)
                .font(.system(size: 13, weight: .heavy))
                .tracking(1.5)
                .foregroundColor(.gray.opacity(0.8))

            Text(metin)
                .font(.system(size: 24, weight: .heavy))
                .italic()
                .foregroundColor(renk)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
    }

    private var aksiyonButonlari: some View {
        HStack(spacing: 12) {
            Button {
                gelirSayfasiAcik = true
            } label: {
                Text("GELİR")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(red: 30/255, green: 40/255, blue: 70/255))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Button {
                giderSayfasiAcik = true
            } label: {
                Text("GİDER")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }

    private func grafikAlan(_ ozet: PanoOzet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GENEL BAKIŞ")
                    .font(.system(size: 15, weight: .heavy))
                    .italic()
                    .tracking(2)
                    .foregroundColor(.gray.opacity(0.8))

                Spacer()

                HStack(spacing: 12) {
                    legendDot(.green, "Gelir")
                    legendDot(.red, "Gider")
                }
            }
            .padding(.horizontal)

            GeometryReader { geo in
                ScrollView(.horizontal, showsIndicators: false) {
                    Chart {
                        ForEach(ozet.grafik) { item in
                            BarMark(
                                x: .value("Periyot", item.baslik),
                                y: .value("Gelir", item.gelir)
                            )
                            .foregroundStyle(Color.green)
                            .position(by: .value("Tür", "Gelir"))

                            BarMark(
                                x: .value("Periyot", item.baslik),
                                y: .value("Gider", item.gider)
                            )
                            .foregroundStyle(Color.red)
                            .position(by: .value("Tür", "Gider"))
                        }
                    }
                    .chartLegend(.hidden)
                    .frame(
                        width: seciliFiltre == .aylik ? 900 : max(geo.size.width - 32, 280),
                        height: 220
                    )
                    .padding(18)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                    .padding(.horizontal)
                }
            }
            .frame(height: 260)
        }
        .padding(.top, 8)
    }

    private func legendDot(_ color: Color, _ text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray.opacity(0.8))
        }
    }

    private func sonIslemlerAlani(_ ozet: PanoOzet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SON İŞLEMLER")
                .font(.system(size: 15, weight: .heavy))
                .italic()
                .tracking(2)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.horizontal)

            ForEach(ozet.sonIslemler.prefix(6)) { islem in
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                islem.tur == "Gelir"
                                ? Color.green.opacity(0.10)
                                : Color(red: 245/255, green: 233/255, blue: 215/255)
                            )
                            .frame(width: 72, height: 72)

                        Image(systemName: islem.tur == "Gelir" ? "banknote" : "wrench.and.screwdriver")
                            .font(.system(size: 26))
                            .foregroundColor(islem.tur == "Gelir" ? .green : .orange)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(islem.baslik.uppercased())
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(
                                Color(red: 30/255, green: 40/255, blue: 70/255)
                            )
                            .lineLimit(2)

                        Text("\(islem.tur) • \(islem.altBaslik)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)

                        Text(formatDate(islem.tarih))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Text("\(islem.tur == "Gelir" ? "+" : "-")\(Int(islem.tutar)) ₺")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundColor(islem.tur == "Gelir" ? .green : .red)
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                .padding(.horizontal)
            }
        }
        .padding(.top, 8)
    }

    @MainActor
    private func verileriYukle() async {
        yukleniyor = true
        hataMesaji = ""

        defer { yukleniyor = false }

        do {
            ozet = try await PanolarService.shared.fetchDashboardData(filtre: seciliFiltre)
        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

private struct GelirKayitlariView: View {
    let kayitlar: [PanoGelirSatiri]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GELİR KAYITLARI")
                                .font(.system(size: 26, weight: .semibold))
                                .italic()
                                .foregroundColor(
                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                )

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 150, height: 3)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)

                        ForEach(kayitlar) { gelir in
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.green.opacity(0.10))
                                        .frame(width: 72, height: 72)

                                    Image(systemName: "banknote")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(gelir.sirketAdi.uppercased())
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundColor(
                                            Color(red: 30/255, green: 40/255, blue: 70/255)
                                        )

                                    Text(gelir.isTuru)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    Text(formatDate(gelir.tarih))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    Text(gelir.odemeAciklamasi)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.green)
                                }

                                Spacer()

                                Text("+\(Int(gelir.alinanTutar)) ₺")
                                    .font(.system(size: 17, weight: .heavy))
                                    .foregroundColor(.green)
                            }
                            .padding(18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

private struct GiderKayitlariView: View {
    let kayitlar: [PanoGiderSatiri]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GİDER KAYITLARI")
                                .font(.system(size: 26, weight: .semibold))
                                .italic()
                                .foregroundColor(
                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                )

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 150, height: 3)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)

                        ForEach(kayitlar) { gider in
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color(red: 245/255, green: 233/255, blue: 215/255))
                                        .frame(width: 72, height: 72)

                                    Image(systemName: gider.tur == "Bakım" ? "wrench.and.screwdriver" : "drop.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.orange)
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(gider.baslik.uppercased())
                                        .font(.system(size: 20, weight: .heavy))
                                        .foregroundColor(
                                            Color(red: 30/255, green: 40/255, blue: 70/255)
                                        )

                                    Text(gider.altBaslik)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)

                                    Text(formatDate(gider.tarih))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("-\(Int(gider.tutar)) ₺")
                                    .font(.system(size: 17, weight: .heavy))
                                    .foregroundColor(.red)
                            }
                            .padding(18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "tr_TR")
    formatter.dateFormat = "dd.MM.yyyy"
    return formatter.string(from: date)
}

#Preview {
    PanolarView()
}

