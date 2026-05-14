import SwiftUI

struct IsEkleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isTuruAdi: String = ""
    @State private var mesaj: String = ""
    @State private var kaydediliyor = false

    var onSaved: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("İş Türü Adı", text: $isTuruAdi)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)

                if !mesaj.isEmpty {
                    Text(mesaj)
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
                    Text(kaydediliyor ? "Kaydediliyor..." : "İş Türünü Kaydet")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .disabled(kaydediliyor)

                Spacer()
            }
            .padding(.top, 30)
            .navigationTitle("İş Türü Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }

    @MainActor
    private func kaydet() async {
        mesaj = ""

        let temizAd = isTuruAdi.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !temizAd.isEmpty else {
            mesaj = "İş türü adı boş olamaz."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            _ = try await JobTypeService.shared.createJobType(name: temizAd)
            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

