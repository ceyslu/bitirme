import SwiftUI

struct GirisView: View {
    
    @State private var hataMesaji = ""

    @State private var telefon: String = ""
    @State private var sifre: String = ""

    @State private var girisYapiliyor = false

    @FocusState private var sifreAlaniAktifMi: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("GİRİŞ YAP")
                                .font(.system(size: 26, weight: .semibold))
                                .italic()
                                .foregroundColor(
                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                )

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 95, height: 3)

                            Text("Telefon numaranız ve 4 haneli şifrenizi girin")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 36)

                        TextField("Telefon Numarası", text: $telefon)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 20)
                            .frame(height: 76)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .padding(.horizontal)
                            .onChange(of: telefon) { _, yeniDeger in
                                let sadeceRakam = yeniDeger.filter { $0.isNumber }
                                telefon = String(sadeceRakam.prefix(11))
                            }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("4 HANELİ ŞİFRE")
                                .font(.system(size: 13, weight: .heavy))
                                .tracking(1.5)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.horizontal)

                            HStack(spacing: 16) {
                                SifreKutusuView(index: 0, sifre: sifre)
                                SifreKutusuView(index: 1, sifre: sifre)
                                SifreKutusuView(index: 2, sifre: sifre)
                                SifreKutusuView(index: 3, sifre: sifre)
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                sifreAlaniAktifMi = true
                            }
                        }

                        if !hataMesaji.isEmpty {
                            Text(hataMesaji)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .padding(.horizontal)
                        }

                        TextField("", text: $sifre)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .focused($sifreAlaniAktifMi)
                            .frame(width: 1, height: 1)
                            .opacity(0.01)
                            .onChange(of: sifre) { _, yeniDeger in
                                let sadeceRakam = yeniDeger.filter { $0.isNumber }
                                sifre = String(sadeceRakam.prefix(4))
                            }

                        Button {
                            Task {
                                await girisYap()
                            }
                        } label: {
                            Text(girisYapiliyor ? "GİRİŞ YAPILIYOR..." : "GİRİŞ YAP")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(
                                    telefon.count >= 10 && sifre.count == 4
                                    ? Color.orange
                                    : Color.orange.opacity(0.45)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .padding(.horizontal)
                        }
                        .disabled(telefon.count < 10 || sifre.count != 4 || girisYapiliyor)

                        VStack(spacing: 16) {
                            NavigationLink(destination: SifremiUnuttumView()) {
                                Text("Şifremi Unuttum")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .underline()
                            }

                            NavigationLink(destination: UyeOlView()) {
                                Text("ÜYE OL")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            
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
            let response = try await AuthService.shared.login(
                phone: telefon,
                pin: sifre
            )

            OturumYonetici.shared.kullaniciyiKaydet(response.kullanici)

        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

#Preview {
    GirisView()
}

