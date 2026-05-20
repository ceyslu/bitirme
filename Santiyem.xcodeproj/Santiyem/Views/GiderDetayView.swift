//
//  GiderDetayView.swift
//  Santiyem
//
//  Created by Ceyda Uslu on 13.05.2026.
//

import SwiftUI

struct GiderDetayView: View {
    let gider: PanoGiderSatiri
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 22) {
                    HStack {
                        Spacer()
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 90, height: 8)
                        Spacer()
                    }
                    .padding(.top, 14)

                    Text("GİDER DETAYI")
                        .font(.system(size: 30, weight: .heavy))
                        .italic()
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                        .frame(maxWidth: .infinity, alignment: .center)

                    detayKart("TÜR", value: gider.tur)
                    detayKart("İŞLEM", value: gider.baslik)
                    detayKart("MAKİNE", value: gider.altBaslik)
                    detayKart("TARİH", value: formatDate(gider.tarih))
                    detayKart("TUTAR", value: "\(gider.tutar.formatted(.number.precision(.fractionLength(0...2)))) ₺")

                    Button {
                        dismiss()
                    } label: {
                        Text("KAPAT")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 74)
                            .background(Color(red: 35/255, green: 47/255, blue: 74/255))
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }

    private func detayKart(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .tracking(2)
                .foregroundColor(.gray.opacity(0.8))

            Text(value)
                .font(.system(size: 22, weight: .heavy))
                .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}

