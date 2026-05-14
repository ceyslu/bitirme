
import SwiftUI

struct MusterilerView: View {

    @State private var musteriler: [Musteri] = []
    @State private var musteriEkleSayfasiAcik = false
    @State private var hataMesaji: String = ""
    @State private var yukleniyor = false

    var body: some View {

        NavigationStack {

            ZStack {

                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView {

                    VStack(alignment: .leading, spacing: 14) {

                        HStack(alignment: .top) {

                            VStack(alignment: .leading, spacing: 6) {

                                Text("MÜŞTERİLER")
                                    .font(.system(size: 26, weight: .semibold))
                                    .italic()
                                    .foregroundColor(
                                        Color(
                                            red: 30/255,
                                            green: 40/255,
                                            blue: 70/255
                                        )
                                    )

                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: 120, height: 3)
                            }

                            Spacer()

                            Button {

                                musteriEkleSayfasiAcik = true

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

                            ProgressView("Müşteriler yükleniyor...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)

                        } else if !hataMesaji.isEmpty {

                            VStack(spacing: 12) {

                                Text(hataMesaji)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)

                                Button("Tekrar Dene") {

                                    Task {
                                        await musterileriYukle()
                                    }
                                }
                                .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)

                        } else if musteriler.isEmpty {

                            VStack(spacing: 12) {

                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 42))
                                    .foregroundColor(.orange)

                                Text("Henüz müşteri eklenmedi")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text("Başlığın yanındaki + butonundan müşteri ekleyebilirsiniz.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70)

                        } else {

                            ForEach(musteriler) { musteri in

                                NavigationLink(
                                    destination: MusteriDetayView(
                                        musteriId: musteri.id
                                    )
                                ) {

                                    musteriKart(musteri)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)

            .sheet(isPresented: $musteriEkleSayfasiAcik) {

                MusteriEkleView {

                    Task {
                        await musterileriYukle()
                    }
                }
            }

            .task {

                await musterileriYukle()
            }
        }
    }

    private func musteriKart(_ musteri: Musteri) -> some View {

        HStack(spacing: 16) {

            ZStack {

                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        Color(
                            red: 250/255,
                            green: 240/255,
                            blue: 225/255
                        )
                    )
                    .frame(width: 76, height: 76)

                Image(systemName: "person.2.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 8) {

                Text(musteri.ad.uppercased())
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(
                        Color(
                            red: 30/255,
                            green: 40/255,
                            blue: 70/255
                        )
                    )
                    .lineLimit(1)

                Text((musteri.not ?? "").uppercased())
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.65))
                    .lineLimit(1)
            }

            Spacer()

            Text("AKTİF")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 26))
    }

    @MainActor
    private func musterileriYukle() async {

        yukleniyor = true
        hataMesaji = ""

        defer {
            yukleniyor = false
        }

        do {

            musteriler = try await CustomerService.shared.fetchCustomers()

        } catch {

            hataMesaji = error.localizedDescription
        }
    }
}
