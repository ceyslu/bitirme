import SwiftUI

struct GiderEkleView: View {
    let makineId: Int
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var tutar = ""
    @State private var litre = ""
    @State private var tarih = Date()

    @State private var kaydediliyor = false
    @State private var mesaj = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        Capsule()
                            .fill(Color.gray.opacity(0.18))
                            .frame(width: 120, height: 10)
                            .padding(.top, 14)

                        Text("GİDER GİRİŞİ YAP")
                            .font(.system(size: 30, weight: .heavy))
                            .italic()
                            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .frame(maxWidth: .infinity, alignment: .center)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("ALINAN MAZOT TUTARI (TL)")
                                .font(.system(size: 15, weight: .heavy))
                                .tracking(2)
                                .foregroundColor(.gray.opacity(0.8))

                            TextField("0.00", text: $tutar)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                                .padding(.horizontal, 22)
                                .frame(height: 88)
                                .background(Color.white.opacity(0.55))
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.white.opacity(0.35))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("ALINAN LİTRE (OPS.)")
                                .font(.system(size: 15, weight: .heavy))
                                .tracking(2)
                                .foregroundColor(.gray.opacity(0.8))

                            TextField("Örn: 45", text: $litre)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 22, weight: .heavy))
                                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                                .padding(.horizontal, 22)
                                .frame(height: 88)
                                .background(Color.white.opacity(0.55))
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.white.opacity(0.35))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("GİDER TARİHİ")
                                .font(.system(size: 15, weight: .heavy))
                                .tracking(2)
                                .foregroundColor(.gray.opacity(0.8))

                            DatePicker(
                                "",
                                selection: $tarih,
                                displayedComponents: .date
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 22)
                            .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
                            .background(Color.white.opacity(0.55))
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.white.opacity(0.35))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if !mesaj.isEmpty {
                            Text(mesaj)
                                .font(.footnote)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        Button {
                            Task {
                                await kaydet()
                            }
                        } label: {
                            Text(kaydediliyor ? "KAYDEDİLİYOR..." : "KAYDET VE EKLE")
                                .font(.system(size: 22, weight: .heavy))
                                .italic()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 78)
                                .background(Color(red: 35/255, green: 47/255, blue: 74/255))
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                        }
                        .disabled(kaydediliyor)

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    @MainActor
    private func kaydet() async {
        mesaj = ""

        let temizTutar = Double(tutar.replacingOccurrences(of: ",", with: ".")) ?? -1
        let temizLitre = Double(litre.replacingOccurrences(of: ",", with: ".")) ?? 0

        guard temizTutar > 0 else {
            mesaj = "Geçerli bir mazot tutarı girin."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        do {
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                mesaj = "Aktif kullanıcı bulunamadı."
                return
            }

            _ = try await FuelExpenseService.shared.createFuelExpense(
                userId: userId,
                machineId: makineId,
                cost: temizTutar,
                liters: temizLitre,
                expenseDate: formatter.string(from: tarih)
            )

            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    GiderEkleView(makineId: 1)
}

