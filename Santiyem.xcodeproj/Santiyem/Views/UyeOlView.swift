//
//  UyeOlView.swift
//  Santiyem
//

import SwiftUI

struct UyeOlView: View {
    @Environment(\.dismiss) var dismiss

    @State private var sirketAdi: String = ""
    @State private var adSoyad: String = ""
    @State private var telefon: String = ""
    @State private var sifre: String = ""

    @State private var mesaj: String = ""
    @State private var kayitOlusturuluyor = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer()

                VStack(spacing: 10) {
                    Text("Üye Ol")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)

                    Text("Bilgilerinizi girerek hesap oluşturun")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                TextField("Şirket Adı", text: $sirketAdi)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)

                TextField("Ad Soyad", text: $adSoyad)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)

                TextField("Telefon Numarası", text: $telefon)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)
                    .onChange(of: telefon) { _, yeniDeger in
                        let sadeceRakam = yeniDeger.filter { $0.isNumber }
                        if sadeceRakam.count <= 11 {
                            telefon = sadeceRakam
                        } else {
                            telefon = String(sadeceRakam.prefix(11))
                        }
                    }

                SecureField("4 Haneli Şifre", text: $sifre)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)
                    .onChange(of: sifre) { _, yeniDeger in
                        let sadeceRakam = yeniDeger.filter { $0.isNumber }
                        if sadeceRakam.count <= 4 {
                            sifre = sadeceRakam
                        } else {
                            sifre = String(sadeceRakam.prefix(4))
                        }
                    }

                if !mesaj.isEmpty {
                    Text(mesaj)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }

                Button {
                    Task {
                        await kayitOl()
                    }
                } label: {
                    Text(kayitOlusturuluyor ? "Kaydediliyor..." : "Kaydı Oluştur")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .padding(.horizontal, 30)
                }
                .disabled(kayitOlusturuluyor)

                Spacer()
            }
        }
        .navigationTitle("Üye Ol")
        .navigationBarTitleDisplayMode(.inline)
    }

    @MainActor
    private func kayitOl() async {
        mesaj = ""

        if sirketAdi.trimmingCharacters(in: .whitespaces).isEmpty ||
            adSoyad.trimmingCharacters(in: .whitespaces).isEmpty ||
            telefon.count < 10 ||
            sifre.count != 4 {

            mesaj = "Lütfen tüm alanları doğru doldurun."
            return
        }

        kayitOlusturuluyor = true
        defer { kayitOlusturuluyor = false }

        do {
            _ = try await AuthService.shared.register(
                companyName: sirketAdi,
                fullName: adSoyad,
                phone: telefon,
                pin: sifre
            )

            dismiss()
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
