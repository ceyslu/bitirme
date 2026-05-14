import SwiftUI

struct BakimEkleView: View {
    let makineId: Int
    var onSaved: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var islemAdi = ""
    @State private var tutar = ""
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

                        Text("BAKIM GİRİŞİ YAP")
                            .font(.system(size: 30, weight: .heavy))
                            .italic()
                            .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .frame(maxWidth: .infinity, alignment: .center)

                        alanBaslik("BAKIM / İŞLEM ADI")
                        normalAlan(placeholder: "Örn: Yağ Değişimi", text: $islemAdi)

                        alanBaslik("BAKIM TUTARI (TL)")
                        normalAlan(placeholder: "0.00", text: $tutar, keyboardType: .decimalPad)

                        alanBaslik("BAKIM TARİHİ")
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

    private func alanBaslik(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .heavy))
            .tracking(2)
            .foregroundColor(.gray.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func normalAlan(
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
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

    @MainActor
    private func kaydet() async {
        mesaj = ""

        let temizIslemAdi = islemAdi.trimmingCharacters(in: .whitespacesAndNewlines)
        let temizTutar = Double(tutar.replacingOccurrences(of: ",", with: ".")) ?? -1

        guard !temizIslemAdi.isEmpty else {
            mesaj = "Bakım işlem adı boş olamaz."
            return
        }

        guard temizTutar > 0 else {
            mesaj = "Geçerli bir bakım tutarı girin."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        do {
            _ = try await BakimGideriService.shared.createMaintenanceExpense(
                machineId: makineId,
                operationName: temizIslemAdi,
                cost: temizTutar,
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
    BakimEkleView(makineId: 1)
}

