import SwiftUI

struct IsTuruEkleView: View {
    @Environment(\.dismiss) private var dismiss

    let isTuru: IsTuru?
    var onSaved: (() -> Void)? = nil

    @State private var isTuruAdi: String = ""
    @State private var mesaj: String = ""
    @State private var kaydediliyor = false
    @State private var silmeUyarisiAcik = false

    init(isTuru: IsTuru? = nil, onSaved: (() -> Void)? = nil) {
        self.isTuru = isTuru
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

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
                            await kaydetVeyaGuncelle()
                        }
                    } label: {
                        Text(kaydediliyor ? "Kaydediliyor..." : butonMetni)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .padding(.horizontal)
                    }
                    .disabled(kaydediliyor)

                    if isTuru != nil {
                        Button(role: .destructive) {
                            silmeUyarisiAcik = true
                        } label: {
                            Text("İş Türünü Sil")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .padding(.horizontal)
                        }
                        .disabled(kaydediliyor)
                    }

                    Spacer()
                }
                .padding(.top, 30)
            }
            .navigationTitle(baslikMetni)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let isTuru {
                    isTuruAdi = isTuru.ad
                }
            }
            .alert("İş türü silinsin mi?", isPresented: $silmeUyarisiAcik) {
                Button("Sil", role: .destructive) {
                    Task {
                        await sil()
                    }
                }

                Button("Vazgeç", role: .cancel) { }
            } message: {
                Text("Bu iş türü kalıcı olarak silinecek.")
            }
        }
    }

    private var baslikMetni: String {
        isTuru == nil ? "İş Türü Ekle" : "İş Türünü Düzenle"
    }

    private var butonMetni: String {
        isTuru == nil ? "İş Türünü Kaydet" : "Değişiklikleri Kaydet"
    }

    @MainActor
    private func kaydetVeyaGuncelle() async {
        mesaj = ""

        let temizAd = isTuruAdi.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !temizAd.isEmpty else {
            mesaj = "İş türü adı boş olamaz."
            return
        }

        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            mesaj = "Aktif kullanıcı bulunamadı."
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            if let isTuru {
                _ = try await JobTypeService.shared.updateJobType(
                    userId: userId,
                    id: isTuru.id,
                    name: temizAd
                )
            } else {
                _ = try await JobTypeService.shared.createJobType(
                    userId: userId,
                    name: temizAd
                )
            }

            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }

    @MainActor
    private func sil() async {
        guard let isTuru else { return }

        guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
            mesaj = "Aktif kullanıcı bulunamadı."
            return
        }

        mesaj = ""
        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            try await JobTypeService.shared.deleteJobType(
                userId: userId,
                id: isTuru.id
            )
            onSaved?()
            dismiss()
        } catch {
            mesaj = error.localizedDescription
        }
    }
}

#Preview {
    IsTuruEkleView(
        isTuru: IsTuru(
            id: 1,
            ad: "Temel Kazı",
            olusturulmaTarihi: nil
        )
    )
}

