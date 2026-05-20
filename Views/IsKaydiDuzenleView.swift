import SwiftUI

struct IsKaydiDuzenleView: View {
    let isKaydi: MusteriIsKaydi
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var odemeDurumu: String
    @State private var odenenTutar: String
    @State private var mesaj = ""
    @State private var kaydediliyor = false

    init(isKaydi: MusteriIsKaydi, onSaved: (() -> Void)? = nil) {
        self.isKaydi = isKaydi
        self.onSaved = onSaved
        _odemeDurumu = State(initialValue: isKaydi.odemeDurumu)
        _odenenTutar = State(initialValue: isKaydi.odenenTutar > 0 ? String(Int(isKaydi.odenenTutar)) : "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        Text("İŞ KAYDI DÜZENLE")
                            .font(.system(size: 30, weight: .heavy))
                            .italic()
                            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 20)

                        VStack(alignment: .leading, spacing: 6) {
                            Text((isKaydi.isTuruAdi ?? "İŞ KAYDI").uppercased())
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                            Text("Toplam Tutar: \(isKaydi.toplamUcret.formatted(.number.precision(.fractionLength(0...2)))) ₺")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.gray.opacity(0.8))
                        }

                        baslik("ÖDEME DURUMU")
                        Picker("Ödeme Durumu", selection: $odemeDurumu) {
                            Text("Bekliyor").tag("bekliyor")
                            Text("Kısmi").tag("kismi")
                            Text("Ödendi").tag("odendi")
                        }
                        .pickerStyle(.segmented)

                        if odemeDurumu == "kismi" {
                            baslik("ÖDENEN TUTAR")
                            TextField("Örn: 5000", text: $odenenTutar)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }

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
                            Text(kaydediliyor ? "KAYDEDİLİYOR..." : "DEĞİŞİKLİKLERİ KAYDET")
                                .font(.system(size: 22, weight: .heavy))
                                .italic()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 72)
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .disabled(kaydediliyor)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private func baslik(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .heavy))
            .tracking(2)
            .foregroundColor(.gray.opacity(0.85))
    }
    @MainActor
    private func kaydet() async {
        mesaj = ""
        kaydediliyor = true
        defer { kaydediliyor = false }

        let paidAmount: Double

        switch odemeDurumu {
        case "odendi":
            paidAmount = isKaydi.toplamUcret

        case "kismi":
            let girilenTutar = Double(odenenTutar.replacingOccurrences(of: ",", with: ".")) ?? -1

            guard girilenTutar >= 0 else {
                mesaj = "Geçerli bir ödenen tutar girin."
                return
            }

            guard girilenTutar <= isKaydi.toplamUcret else {
                mesaj = "Ödenen tutar toplam tutardan büyük olamaz."
                return
            }

            paidAmount = girilenTutar

        default:
            paidAmount = 0
        }

        do {
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                mesaj = "Aktif kullanıcı bulunamadı."
                return
            }

            _ = try await JobService.shared.updatePaymentStatus(
                userId: userId,
                jobId: isKaydi.id,
                paymentStatus: odemeDurumu,
                paidAmount: paidAmount
            )

            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }

}

#Preview {
    IsKaydiDuzenleView(
        isKaydi: MusteriIsKaydi(
            id: 1,
            isTarihi: "2026-04-24",
            calismaSuresi: 4,
            saatlikUcret: 2500,
            yolUcreti: 500,
            toplamUcret: 10500,
            odenenTutar: 3000,
            odemeDurumu: "kismi",
            not: nil,
            makineAdi: "JSP",
            isTuruAdi: "Kanal Dolgu"
        )
    )
}

