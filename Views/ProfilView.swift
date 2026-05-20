import SwiftUI

struct ProfilView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var oturum = OturumYonetici.shared

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("PROFİL")
                                .font(.system(size: 26, weight: .semibold))
                                .italic()
                                .foregroundColor(
                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                )

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 65, height: 3)
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)

                        if let kullanici = oturum.aktifKullanici {
                            bilgiKart("ŞİRKET ADI", deger: kullanici.sirketAdi)
                            bilgiKart("AD SOYAD", deger: kullanici.adSoyad)
                            bilgiKart("TELEFON", deger: kullanici.telefon)

                            NavigationLink(destination: SifremiUnuttumView()) {
                                Text("PIN DEĞİŞTİR")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.orange)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .padding(.horizontal)
                            }
                            .buttonStyle(.plain)

                            Button {
                                oturum.cikisYap()
                                dismiss()
                            } label: {
                                Text("ÇIKIŞ YAP")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(Color.red.opacity(0.85))
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .padding(.horizontal)
                            }
                        } else {
                            Text("Aktif kullanıcı bulunamadı.")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func bilgiKart(_ baslik: String, deger: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(baslik)
                .font(.system(size: 13, weight: .heavy))
                .tracking(1.5)
                .foregroundColor(.gray.opacity(0.8))
                .padding(.horizontal)

            Text(deger)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 30/255, green: 40/255, blue: 70/255))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .frame(height: 76)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal)
        }
    }
}

#Preview {
    ProfilView()
}

