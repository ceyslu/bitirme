import SwiftUI

struct UyeOlView: View {
    @State private var sirketAdi: String = ""
    @State private var adSoyad: String = ""
    @State private var telefon: String = ""
    @State private var sifre: String = ""

    @State private var mesaj: String = ""
    @State private var kayitOlusturuluyor = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ÜYE OL")
                            .font(.system(size: 26, weight: .semibold))
                            .italic()
                            .foregroundColor(
                                Color(red: 30/255, green: 40/255, blue: 70/255)
                            )

                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 82, height: 3)

                        Text("Bilgilerinizi girerek hesap oluşturun")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)

                    alanBasligi("ŞİRKET ADI")
                    normalAlan("Şirket Adı", text: $sirketAdi)

                    alanBasligi("AD SOYAD")
                    normalAlan("Ad Soyad", text: $adSoyad)

                    alanBasligi("TELEFON NUMARASI")
                    normalAlan("Telefon Numarası", text: $telefon, keyboardType: .numberPad)
                        .onChange(of: telefon) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }
                            telefon = String(sadeceRakam.prefix(11))
                        }

                    alanBasligi("4 HANELİ ŞİFRE")
                    normalAlan("4 Haneli Şifre", text: $sifre, keyboardType: .numberPad, isSecure: true)
                        .onChange(of: sifre) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }
                            sifre = String(sadeceRakam.prefix(4))
                        }

                    if !mesaj.isEmpty {
                        Text(mesaj)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button {
                        Task {
                            await kayitOl()
                        }
                    } label: {
                        Text(kayitOlusturuluyor ? "KAYIT OLUŞTURULUYOR..." : "KAYDI OLUŞTUR")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .padding(.horizontal)
                    }
                    .disabled(kayitOlusturuluyor)

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func alanBasligi(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .heavy))
            .tracking(1.5)
            .foregroundColor(.gray.opacity(0.8))
            .padding(.horizontal)
    }

    private func normalAlan(
        _ placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false
    ) -> some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: text)
            } else {
                TextField(placeholder, text: text)
            }
        }
        .keyboardType(keyboardType)
        .padding(.horizontal, 20)
        .frame(height: 76)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .padding(.horizontal)
    }

    @MainActor
    private func kayitOl() async {
        mesaj = ""

        if sirketAdi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            adSoyad.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            telefon.count < 10 ||
            sifre.count != 4 {

            mesaj = "Lütfen tüm alanları doğru doldurun."
            return
        }

        kayitOlusturuluyor = true
        defer { kayitOlusturuluyor = false }

        do {
            let response = try await AuthService.shared.register(
                companyName: sirketAdi,
                fullName: adSoyad,
                phone: telefon,
                pin: sifre
            )

            OturumYonetici.shared.kullaniciyiKaydet(response.kullanici)
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        UyeOlView()
    }
}

