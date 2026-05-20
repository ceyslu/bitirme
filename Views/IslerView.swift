import SwiftUI

// Ekranda göstereceğimiz hesaplanmış iş türü özeti
struct IsTuruOzet: Identifiable {
    let id: Int
    let ad: String
    let haftalikKazanc: Double
    let aylikKazanc: Double
}

struct IslerView: View {
    @State private var isTurleri: [IsTuruOzet] = []
    @State private var hataMesaji: String = ""
    @State private var yukleniyor = false
    @State private var isTuruEkleSayfasiAcik = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("İŞ TÜRLERİ")
                                    .font(.system(size: 26, weight: .semibold))
                                    .italic()
                                    .foregroundColor(
                                        Color(red: 30/255, green: 40/255, blue: 70/255)
                                    )

                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: 110, height: 3)
                            }

                            Spacer()

                            Button {
                                isTuruEkleSayfasiAcik = true
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange)
                                        .frame(width: 46, height: 46)
                                        .shadow(
                                            color: .black.opacity(0.05),
                                            radius: 4,
                                            x: 0,
                                            y: 2
                                        )

                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)

                        if yukleniyor {
                            ProgressView("İş türleri yükleniyor...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else if !hataMesaji.isEmpty {
                            Text(hataMesaji)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.top, 50)
                        } else if isTurleri.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "briefcase")
                                    .font(.system(size: 42))
                                    .foregroundColor(.orange)

                                Text("Henüz iş türü yok")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text("Sağ üstteki + butonundan iş türü ekleyebilirsiniz.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70)
                        } else {
                            ForEach(isTurleri) { isTuru in
                                NavigationLink(
                                    destination: IsTuruEkleView(
                                        isTuru: IsTuru(
                                            id: isTuru.id,
                                            ad: isTuru.ad,
                                            olusturulmaTarihi: nil
                                        ),
                                        onSaved: {
                                            Task {
                                                await verileriYukle()
                                            }
                                        }
                                    )
                                ) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color(red: 245/255, green: 233/255, blue: 215/255))
                                                .frame(width: 72, height: 72)

                                            Image(systemName: "briefcase.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(.orange)
                                        }

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(isTuru.ad.uppercased())
                                                .font(.system(size: 20, weight: .heavy))
                                                .foregroundColor(
                                                    Color(red: 30/255, green: 40/255, blue: 70/255)
                                                )
                                                .lineLimit(2)

                                            Text("Haftalık: \(Int(isTuru.haftalikKazanc)) ₺")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.gray)

                                            Text("Aylık: \(Int(isTuru.aylikKazanc)) ₺")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                    .padding(18)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isTuruEkleSayfasiAcik) {
                IsTuruEkleView {
                    Task {
                        await verileriYukle()
                    }
                }
            }
            .task {
                await verileriYukle()
            }
        }
    }

    @MainActor
    private func verileriYukle() async {
        yukleniyor = true
        hataMesaji = ""

        defer { yukleniyor = false }

        do {
            // İş türleri ve iş kayıtları aynı anda çekilir
            guard let userId = OturumYonetici.shared.aktifKullanici?.id else {
                hataMesaji = "Aktif kullanıcı bulunamadı."
                return
            }

            async let jobTypesTask = JobTypeService.shared.fetchJobTypes(userId: userId)

            async let recordsTask = JobRecordService.shared.fetchJobRecords(userId: userId)


            let gelenIsTurleri = try await jobTypesTask
            let gelenKayitlar = try await recordsTask

            isTurleri = ozetleriHesapla(
                isTurleri: gelenIsTurleri,
                kayitlar: gelenKayitlar
            )
        } catch {
            hataMesaji = error.localizedDescription
        }
    }

    // İş kayıtlarını kullanarak haftalık ve aylık toplamları hesaplar
    private func ozetleriHesapla(
        isTurleri: [IsTuru],
        kayitlar: [IsKaydi]
    ) -> [IsTuruOzet] {
        let calendar = Calendar.current
        let simdi = Date()
        let yediGunOnce = calendar.date(byAdding: .day, value: -7, to: simdi) ?? simdi

        return isTurleri.map { isTuru in
            let ilgiliKayitlar = kayitlar.filter { $0.isTuruId == isTuru.id }

            let haftalikToplam = ilgiliKayitlar.reduce(0.0) { toplam, kayit in
                guard let tarih = tarihCevir(kayit.isTarihi) else { return toplam }
                return tarih >= yediGunOnce ? toplam + kayit.toplamUcret : toplam
            }

            let aylikToplam = ilgiliKayitlar.reduce(0.0) { toplam, kayit in
                guard let tarih = tarihCevir(kayit.isTarihi) else { return toplam }
                return calendar.isDate(tarih, equalTo: simdi, toGranularity: .month)
                    ? toplam + kayit.toplamUcret
                    : toplam
            }

            return IsTuruOzet(
                id: isTuru.id,
                ad: isTuru.ad,
                haftalikKazanc: haftalikToplam,
                aylikKazanc: aylikToplam
            )
        }
    }

    // Backend'den gelen tarih string'ini Date'e çevirir
    private func tarihCevir(_ tarihMetni: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let tarih = formatter.date(from: tarihMetni) {
            return tarih
        }

        let yedekFormatter = ISO8601DateFormatter()
        yedekFormatter.formatOptions = [.withInternetDateTime]
        return yedekFormatter.date(from: tarihMetni)
    }
}

#Preview {
    IslerView()
}

