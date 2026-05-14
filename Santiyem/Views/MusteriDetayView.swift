import SwiftUI

struct MusteriDetayView: View {
    let musteriId: Int

    @Environment(\.dismiss) private var dismiss

    @State private var musteriDetay: MusteriDetay?
    @State private var yukleniyor = false
    @State private var hataMesaji = ""
    @State private var secilenIsDetayi: MusteriIsKaydi?

    @State private var isEkleSayfasiAcik = false
    @State private var duzenlenenIs: MusteriIsKaydi?

    private var odenmeyenIsler: [MusteriIsKaydi] {
        guard let musteriDetay else { return [] }
        return musteriDetay.isler.filter { $0.kalanTutar > 0 }
    }

    private var toplamBekleyenOdeme: Double {
        odenmeyenIsler.reduce(0) { $0 + $1.kalanTutar }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 242/255, green: 242/255, blue: 247/255)
                    .ignoresSafeArea()

                if yukleniyor {
                    ProgressView("Müşteri bilgileri yükleniyor...")
                } else if !hataMesaji.isEmpty {
                    Text(hataMesaji)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                } else if let musteriDetay {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 25) {
                            ustAlan(musteriDetay)
                            ozetKartlar(musteriDetay)
                            yeniIsButonu

                            if !odenmeyenIsler.isEmpty {
                                odenmeyenIslerAlani
                            }

                            Text("İŞ GEÇMİŞİ")
                                .font(.system(size: 15, weight: .heavy))
                                .italic()
                                .tracking(2)
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.horizontal, 20)

                            VStack(spacing: 16) {
                                ForEach(musteriDetay.isler) { isKaydi in
                                    isKart(isKaydi)
                                        .onTapGesture {
                                            secilenIsDetayi = isKaydi
                                        }
                                }
                            }
                            .padding(.horizontal, 18)

                            Spacer(minLength: 30)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $isEkleSayfasiAcik) {
                if let musteriDetay {
                    MusteriIsEkleView(
                        musteriId: musteriDetay.id,
                        musteriAdi: musteriDetay.ad,
                        onSaved: { Task { await detayiYukle() } }
                    )
                }
            }
            .sheet(item: $secilenIsDetayi) { isKaydi in
                MusteriIsDetayFisiView(isKaydi: isKaydi)
            }
            .sheet(item: $duzenlenenIs) { secilenIs in
                IsKaydiDuzenleView(
                    isKaydi: secilenIs,
                    onSaved: { Task { await detayiYukle() } }
                )
            }
            .task {
                await detayiYukle()
            }
        }
    }

    private func ustAlan(_ musteri: MusteriDetay) -> some View {
        HStack(spacing: 15) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(musteri.ad.uppercased())
                    .font(.system(size: 26, weight: .heavy))
                    .italic()
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                if let not = musteri.not, !not.isEmpty {
                    Text(not.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func ozetKartlar(_ musteri: MusteriDetay) -> some View {
        let toplamCiro = musteri.isler.reduce(0) { $0 + $1.toplamUcret }
        let kalanAlacak = musteri.isler.reduce(0) { $0 + $1.kalanTutar }

        return HStack(spacing: 12) {
            VStack(alignment: .center, spacing: 6) {
                Text("TOPLAM CİRO")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray.opacity(0.7))

                Text("\(Int(toplamCiro)) ₺")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)

            VStack(alignment: .center, spacing: 6) {
                Text("KALAN ALACAK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray.opacity(0.7))

                Text("\(Int(kalanAlacak)) ₺")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundColor(Color(red: 220/255, green: 80/255, blue: 80/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(Color(red: 220/255, green: 80/255, blue: 80/255).opacity(0.35), lineWidth: 1.5)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, 18)
    }

    private var yeniIsButonu: some View {
        Button {
            isEkleSayfasiAcik = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))

                Text("YENİ İŞ BAŞLAT")
                    .font(.system(size: 21, weight: .heavy))
                    .italic()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 35))
            .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 18)
    }

    private var odenmeyenIslerAlani: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ÖDENMEYEN İŞLER")
                    .font(.system(size: 15, weight: .heavy))
                    .italic()
                    .tracking(2)
                    .foregroundColor(.gray.opacity(0.6))

                Spacer()

                Text("Toplam: \(Int(toplamBekleyenOdeme)) ₺")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 14) {
                ForEach(odenmeyenIsler) { isKaydi in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.orange.opacity(0.10))
                                .frame(width: 64, height: 64)

                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 23))
                                .foregroundColor(.orange)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text((isKaydi.isTuruAdi ?? "İŞ").uppercased())
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                            Text("\(formatTarih(isKaydi.isTarihi)) • \((isKaydi.makineAdi ?? "MAKİNE").uppercased())")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray.opacity(0.65))

                            Text("Kalan ödeme: \(Int(isKaydi.kalanTutar)) ₺")
                                .font(.system(size: 13, weight: .heavy))
                                .foregroundColor(.red.opacity(0.85))
                        }

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
                    .onTapGesture {
                        secilenIsDetayi = isKaydi
                    }
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func isKart(_ isKaydi: MusteriIsKaydi) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(renkArkaPlan(isKaydi.odemeDurumu))
                        .frame(width: 68, height: 68)

                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ikonRenk(isKaydi.odemeDurumu))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text((isKaydi.isTuruAdi ?? "İŞ").uppercased())
                        .font(.system(size: 19, weight: .bold))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                    Text("\(formatTarih(isKaydi.isTarihi)) • \((isKaydi.makineAdi ?? "MAKİNE").uppercased())")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray.opacity(0.5))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(isKaydi.toplamUcret)) ₺")
                        .font(.system(size: 21, weight: .heavy))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                    HStack(spacing: 8) {
                        Button {
                            duzenlenenIs = isKaydi
                        } label: {
                            Text("DÜZENLE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(.plain)

                        Text(odemeDurumuMetni(isKaydi.odemeDurumu))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
            .padding(15)

            if isKaydi.odemeDurumu == "kismi" {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 10)

                    HStack {
                        Text("TAHSİLAT: \(Int(isKaydi.odenenTutar)) ₺")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.indigo)

                        Spacer()

                        Text("BAKİYE: \(Int(isKaydi.kalanTutar)) ₺")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal, 15)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 8)

                            Capsule()
                                .fill(Color.indigo)
                                .frame(
                                    width: geo.size.width * CGFloat(isKaydi.odenenTutar / max(isKaydi.toplamUcret, 1)),
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 15)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 28))
    }

    @MainActor
    private func detayiYukle() async {
        yukleniyor = true
        hataMesaji = ""

        defer { yukleniyor = false }

        do {
            musteriDetay = try await CustomerService.shared.fetchCustomerDetail(id: musteriId)
        } catch {
            hataMesaji = error.localizedDescription
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

        return tarihMetni
    }

    private func odemeDurumuMetni(_ durum: String) -> String {
        switch durum {
        case "odendi":
            return "ÖDENDİ"
        case "kismi":
            return "KISMİ"
        default:
            return "BEKLİYOR"
        }
    }

    private func ikonRenk(_ durum: String) -> Color {
        switch durum {
        case "odendi":
            return .green
        case "kismi":
            return .indigo
        default:
            return .orange
        }
    }

    private func renkArkaPlan(_ durum: String) -> Color {
        ikonRenk(durum).opacity(0.08)
    }
}

#Preview {
    MusteriDetayView(musteriId: 1)
}

