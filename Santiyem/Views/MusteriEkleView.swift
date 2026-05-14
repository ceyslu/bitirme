import SwiftUI

struct MusteriEkleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var musteriAdi: String = ""
    @State private var projeAdi: String = ""
    @State private var telefon: String = ""
    @State private var mesaj: String = ""
    @State private var kaydediliyor = false

    var onSaved: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ustTutamaç

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            Text("YENİ MÜŞTERİ EKLE")
                                .font(.system(size: 34, weight: .heavy))
                                .italic()
                                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 22)

                            alanBasligi("MÜŞTERİ ADI / ÜNVANI")
                            iconluTextField(
                                icon: "person.2",
                                iconColor: .orange,
                                placeholder: "ÖRN: MEHMET ÖZ",
                                text: $musteriAdi
                            )

                            alanBasligi("PROJE ADI / LOKASYON")
                            iconluTextField(
                                icon: "waveform.path.ecg",
                                iconColor: .orange,
                                placeholder: "ÖRN: EGE PLAZA",
                                text: $projeAdi
                            )

                            alanBasligi("TELEFON NUMARASI")
                            iconluTextField(
                                icon: "phone",
                                iconColor: .orange,
                                placeholder: "05XX XXX XX XX",
                                text: $telefon
                            )
                            .keyboardType(.numberPad)
                            .onChange(of: telefon) { _, yeniDeger in
                                let sadeceRakam = yeniDeger.filter { $0.isNumber }

                                if sadeceRakam.count <= 11 {
                                    telefon = sadeceRakam
                                } else {
                                    telefon = String(sadeceRakam.prefix(11))
                                }
                            }

                            if !mesaj.isEmpty {
                                Text(mesaj)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                            }

                            Button {
                                Task {
                                    await kaydet()
                                }
                            } label: {
                                Text(kaydediliyor ? "KAYDEDİLİYOR..." : "KAYDET VE LİSTEYE EKLE")
                                    .font(.system(size: 22, weight: .heavy))
                                    .italic()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 78)
                                    .background(Color(red: 35/255, green: 47/255, blue: 74/255))
                                    .clipShape(RoundedRectangle(cornerRadius: 28))
                            }
                            .disabled(kaydediliyor)

                            Spacer(minLength: 30)
                        }
                        .padding(.horizontal, 26)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }

    private var ustTutamaç: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 110, height: 10)
                .padding(.top, 14)
                .padding(.bottom, 20)
        }
    }

    private func alanBasligi(_ baslik: String) -> some View {
        Text(baslik)
            .font(.system(size: 15, weight: .heavy))
            .tracking(2)
            .foregroundColor(Color.gray.opacity(0.85))
    }

    private func iconluTextField(
        icon: String,
        iconColor: Color,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 34)

            TextField(placeholder, text: text)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled(true)
        }
        .padding(.horizontal, 22)
        .frame(height: 92)
        .background(Color.white.opacity(0.55))
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }

    @MainActor
    private func kaydet() async {
        mesaj = ""

        let temizAd = musteriAdi.trimmingCharacters(in: .whitespacesAndNewlines)
        let temizProje = projeAdi.trimmingCharacters(in: .whitespacesAndNewlines)
        let temizTelefon = telefon.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !temizAd.isEmpty else {
            mesaj = "Müşteri adı boş olamaz."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            _ = try await CustomerService.shared.createCustomer(
                name: temizAd,
                phone: temizTelefon,
                note: temizProje
            )

            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    MusteriEkleView()
}

