//
//  GirisView.swift
//  Santiyem
//

import SwiftUI

// Bu ekran uygulamanın giriş ekranıdır
// Kullanıcı telefon numarası ve 4 haneli PIN ile giriş yapar
// Ekran açılınca sayı klavyesi otomatik açılır
// Kutulara dokunulunca klavye tekrar aktif olur

struct GirisView: View {
    // Giriş başarılı mı kontrolü
    @State private var girisBasarili = false

    // Hata mesajı göstermek için
    @State private var hataMesaji = ""

    // Kullanıcının girdiği telefon burada tutulur
    @State private var telefon: String = ""

    // Kullanıcının girdiği 4 haneli şifre burada tutulur
    @State private var sifre: String = ""

    // Giriş isteği sürüyor mu
    @State private var girisYapiliyor = false

    // Gizli TextField'ın odakta olup olmadığını kontrol eder
    @FocusState private var sifreAlaniAktifMi: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    VStack(spacing: 12) {
                        Text("Giriş Yap")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.orange)

                        Text("Telefon numaranız ve 4 haneli şifrenizi girin")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }

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

                    HStack(spacing: 16) {
                        SifreKutusuView(index: 0, sifre: sifre)
                        SifreKutusuView(index: 1, sifre: sifre)
                        SifreKutusuView(index: 2, sifre: sifre)
                        SifreKutusuView(index: 3, sifre: sifre)
                    }
                    .onTapGesture {
                        sifreAlaniAktifMi = true
                    }

                    if !hataMesaji.isEmpty {
                        Text(hataMesaji)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    TextField("", text: $sifre)
                        .keyboardType(.numberPad)
                        .textContentType(.oneTimeCode)
                        .focused($sifreAlaniAktifMi)
                        .frame(width: 1, height: 1)
                        .opacity(0.01)
                        .onChange(of: sifre) { _, yeniDeger in
                            let sadeceRakam = yeniDeger.filter { $0.isNumber }

                            if sadeceRakam.count <= 4 {
                                sifre = sadeceRakam
                            } else {
                                sifre = String(sadeceRakam.prefix(4))
                            }
                        }

                    Button {
                        Task {
                            await girisYap()
                        }
                    } label: {
                        Text(girisYapiliyor ? "Giriş Yapılıyor..." : "Giriş Yap")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                telefon.count >= 10 && sifre.count == 4
                                ? Color.orange
                                : Color.orange.opacity(0.4)
                            )
                            .foregroundColor(.black)
                            .cornerRadius(16)
                            .padding(.horizontal, 30)
                    }
                    .disabled(telefon.count < 10 || sifre.count != 4 || girisYapiliyor)

                    NavigationLink(destination: SifremiUnuttumView()) {
                        Text("Şifremi Unuttum")
                            .foregroundColor(.white)
                            .underline()
                    }

                    NavigationLink(destination: UyeOlView()) {
                        Text("Üye Ol")
                            .foregroundColor(.orange)
                            .bold()
                    }
                    .navigationDestination(isPresented: $girisBasarili) {
                        ContentView()
                    }

                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    sifreAlaniAktifMi = true
                }
            }
        }
    }

    @MainActor
    private func girisYap() async {
        hataMesaji = ""

        if telefon.count < 10 || sifre.count != 4 {
            hataMesaji = "Telefon numarası ve 4 haneli şifre girin"
            return
        }

        girisYapiliyor = true
        defer { girisYapiliyor = false }

        do {
            _ = try await AuthService.shared.login(
                phone: telefon,
                pin: sifre
            )
            girisBasarili = true
        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

#Preview {
    GirisView()
}
