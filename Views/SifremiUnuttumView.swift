import SwiftUI

struct SifremiUnuttumView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var telefon: String = ""
    @State private var yeniSifre: String = ""

    @State private var mesaj: String = ""
    @State private var yukleniyor = false

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ŞİFREMİ UNUTTUM")
                            .font(.system(size: 26, weight: .semibold))
                            .italic()
                            .foregroundColor(
                                Color(red: 30/255, green: 40/255, blue: 70/255)
                            )

                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 165, height: 3)

                        Text("Telefon numaranızı ve yeni 4 haneli şifrenizi girin")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)

                    alanBasligi("TELEFON NUMARASI")
                    normalAlan("Telefon Numarası", text: $telefon, keyboardType: .numberPad)
                        .onChange(of: telefon) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }
                            telefon = String(sadeceRakam.prefix(11))
                        }

                    alanBasligi("YENİ 4 HANELİ ŞİFRE")
                    normalAlan("Yeni 4 Haneli Şifre", text: $yeniSifre, keyboardType: .numberPad, isSecure: true)
                        .onChange(of: yeniSifre) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }
                            yeniSifre = String(sadeceRakam.prefix(4))
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
                            await sifreyiGuncelle()
                        }
                    } label: {
                        Text(yukleniyor ? "GÜNCELLENİYOR..." : "ŞİFREYİ GÜNCELLE")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .padding(.horizontal)
                    }
                    .disabled(yukleniyor)

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
    private func sifreyiGuncelle() async {
        mesaj = ""

        guard telefon.count >= 10, yeniSifre.count == 4 else {
            mesaj = "Telefon ve yeni şifre alanlarını doğru doldurun."
            return
        }

        yukleniyor = true
        defer { yukleniyor = false }

        do {
            try await AuthService.shared.resetPin(
                phone: telefon,
                newPin: yeniSifre
            )
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SifremiUnuttumView()
    }
}

