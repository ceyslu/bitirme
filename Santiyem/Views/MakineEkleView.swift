//
//  MakineEkleView.swift
//  Santiyem
//

import SwiftUI

struct MakineEkleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var makineAdi: String = ""
    @State private var saatlikUcret: String = ""
    @State private var hataMesaji: String = ""
    @State private var kaydediliyor = false

    var onSaved: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Makine Adı", text: $makineAdi)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                TextField("Saatlik Ücret", text: $saatlikUcret)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                if !hataMesaji.isEmpty {
                    Text(hataMesaji)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                Button {
                    Task {
                        await makineyiKaydet()
                    }
                } label: {
                    Text(kaydediliyor ? "Kaydediliyor..." : "Makineyi Kaydet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(kaydediliyor)

                Spacer()
            }
            .navigationTitle("Makine Ekle")
        }
    }

    @MainActor
    private func makineyiKaydet() async {
        hataMesaji = ""

        let temizAd = makineAdi.trimmingCharacters(in: .whitespacesAndNewlines)
        let temizUcretMetni = saatlikUcret.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !temizAd.isEmpty else {
            hataMesaji = "Makine adı boş olamaz"
            return
        }

        guard let ucret = Double(temizUcretMetni.replacingOccurrences(of: ",", with: ".")) else {
            hataMesaji = "Geçerli bir saatlik ücret girin"
            return
        }

        kaydediliyor = true
        defer { kaydediliyor = false }

        do {
            _ = try await MachineService.shared.createMachine(
                name: temizAd,
                hourlyPrice: ucret
            )

            onSaved?()
            dismiss()
        } catch {
            hataMesaji = error.localizedDescription
        }
    }
}

