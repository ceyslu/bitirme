import SwiftUI

struct MusteriEkleView: View {
    @Environment(\.dismiss) private var dismiss

    var onSaved: (() -> Void)? = nil

    @State private var musteriAdi: String = ""
    @State private var projeNotu: String = ""
    @State private var telefon: String = ""

    @State private var hataMesaji: String = ""
    @State private var kaydediliyor = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("MÜŞTERİ EKLE")
                                .font(.system(size: 26, weight: .semibold))
                                .italic()
                                .foregroundColor(
                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                )

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 120, height: 3)

                            Text("Müşteri bilgilerini girerek yeni kayıt oluşturun")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)

                        alanBasligi("MÜŞTERİ ADI / ÜNVAN")
                        normalAlan("Müşteri Adı", text: $musteriAdi)

                        alanBasligi("PROJE / NOT")
                        normalAlan("Proje / Lokasyon / Not", text: $projeNotu)

                        alanBasligi("TELEFON")
                        normalAlan("Telefon Numarası", text: $telefon, keyboardType: .numberPad)
                            .onChange(of: telefon) { _, yeniDeger in
                                let sadeceRakam = yeniDeger.filter { $0.isNumber }
                                telefon = String(sadeceRakam.prefix(11))
                            }

                        if !hataMesaji.isEmpty {
                            Text(hataMesaji)
                                .foregroundColor(.red)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        Button {
                            Task {
                                await kaydet()
                            }
                        } label: {
                            Text(kaydediliyor ? "KAYDEDİLİYOR..." : "KAYDI OLUŞTUR")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 62)
                                .background(Color.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                                .padding(.horizontal)
                        }
                        .disabled(kaydediliyor)

                        Spacer(minLength: 40)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
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
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding(.horizontal, 20)
            .frame(height: 76)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal)
    }

    @MainActor
    private func kaydet() async {
        hataMesaji = ""

        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            hataMesaji = "Aktif kullanıcı bulunamadı."
            return
        }

        if musteriAdi.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hataMesaji = "Müşteri adı boş olamaz."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            _ = try await CustomerService.shared.createCustomer(
                userId: userId,
                name: musteriAdi,
                phone: telefon.isEmpty ? nil : telefon,
                note: projeNotu.isEmpty ? nil : projeNotu
            )

            onSaved?()
            dismiss()
        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        MusteriEkleView()
    }
}

