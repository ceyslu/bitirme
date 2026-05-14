//
//  MakinelerView.swift
//  Santiyem
//

import SwiftUI

struct MakinelerView: View {
    @State private var makineler: [Makine] = []
    @State private var makineEkleSayfasiAcik = false
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
                                Text("MAKİNE PARKI")
                                    .font(.system(size: 26, weight: .semibold))
                                    .italic()
                                    .foregroundColor(
                                        Color(red: 30/255, green: 40/255, blue: 70/255)
                                    )

                                Rectangle()
                                    .fill(Color.orange)
                                    .frame(width: 120, height: 3)
                            }

                            Spacer()

                            Button {
                                makineEkleSayfasiAcik = true
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
                            ProgressView("Makineler yükleniyor...")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 50)
                        } else if !hataMesaji.isEmpty {
                            VStack(spacing: 12) {
                                Text(hataMesaji)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)

                                Button("Tekrar Dene") {
                                    Task {
                                        await makineleriYukle()
                                    }
                                }
                                .foregroundColor(.orange)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else if makineler.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "truck.box")
                                    .font(.system(size: 42))
                                    .foregroundColor(.orange)

                                Text("Henüz makine eklenmedi")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text("Başlığın yanındaki + butonundan makine ekleyebilirsiniz.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 70)
                        } else {
                            ForEach(makineler) { makine in
                                NavigationLink(
                                    destination: MakineDuzenleView(
                                        makine: makine,
                                        onSaved: {
                                            Task {
                                                await makineleriYukle()
                                            }
                                        }
                                    )
                                ) {
                                    MakineKartView(makine: makine)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProfilView()) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("Y")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                )

                            Text("PROFİL")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                    }
                }
            }
            .sheet(isPresented: $makineEkleSayfasiAcik) {
                MakineEkleView {
                    Task {
                        await makineleriYukle()
                    }
                }
            }
            .task {
                await makineleriYukle()
            }
        }
    }

    @MainActor
    private func makineleriYukle() async {
        yukleniyor = true
        hataMesaji = ""

        defer { yukleniyor = false }

        do {
            makineler = try await MachineService.shared.fetchMachines()
        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

#Preview {
    MakinelerView()
}

