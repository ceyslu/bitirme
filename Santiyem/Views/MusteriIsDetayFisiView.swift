//
//  MusteriIsDetayFisiView.swift
//  Santiyem
//
//  Created by Ceyda Uslu on 14.05.2026.
//
import SwiftUI

struct MusteriIsDetayFisiView: View {
    let isKaydi: MusteriIsKaydi
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("İŞ DETAYI")
                                .font(.system(size: 28, weight: .heavy))
                                .italic()
                                .foregroundColor(Color(red: 30/255, green: 40/255, blue: 70/255))

                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 110, height: 3)
                        }
                        .padding(.top, 10)

                        detaySatiri("İŞ TÜRÜ", isKaydi.isTuruAdi ?? "-")
                        detaySatiri("TARİH", formatTarih(isKaydi.isTarihi))
                        detaySatiri("MAKİNE", isKaydi.makineAdi ?? "-")
                        detaySatiri("ÇALIŞMA SÜRESİ", formatSure(isKaydi.toplamSaat))
                        detaySatiri("SAATLİK ÜCRET", "\(Int(isKaydi.saatlikUcret)) ₺")
                        detaySatiri("YOL ÜCRETİ", "\(Int(isKaydi.yolUcreti)) ₺")
                        detaySatiri("TOPLAM TUTAR", "\(Int(isKaydi.toplamUcret)) ₺")
                        detaySatiri("ÖDENEN", "\(Int(isKaydi.odenenTutar)) ₺")
                        detaySatiri("KALAN", "\(Int(isKaydi.kalanTutar)) ₺")
                        detaySatiri("ÖDEME DURUMU", odemeDurumuMetni(isKaydi.odemeDurumu))
                        detaySatiri("NOT", (isKaydi.not?.isEmpty == false ? isKaydi.not! : "-"))

                        Button {
                            dismiss()
                        } label: {
                            Text("KAPAT")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(Color(red: 30/255, green: 40/255, blue: 70/255))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private func detaySatiri(_ baslik: String, _ deger: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(baslik)
                .font(.system(size: 13, weight: .heavy))
                .tracking(1.4)
                .foregroundColor(.gray.opacity(0.75))

            Text(deger)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(red: 30/255, green: 40/255, blue: 70/255))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private func formatTarih(_ tarihMetni: String) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "tr_TR")
        displayFormatter.dateFormat = "dd.MM.yyyy"

        let isoFormatter1 = ISO8601DateFormatter()
        isoFormatter1.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter1.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        let isoFormatter2 = ISO8601DateFormatter()
        isoFormatter2.formatOptions = [.withInternetDateTime]

        if let date = isoFormatter2.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        return tarihMetni
    }

    private func formatSure(_ saatDecimal: Double) -> String {
        let toplamDakika = Int((saatDecimal * 60).rounded())
        let saat = toplamDakika / 60
        let dakika = toplamDakika % 60

        if dakika == 0 { return "\(saat) saat" }
        if saat == 0 { return "\(dakika) dk" }
        return "\(saat) saat \(dakika) dk"
    }

    private func odemeDurumuMetni(_ durum: String) -> String {
        switch durum {
        case "odendi":
            return "ÖDENDİ"
        case "kismi":
            return "KISMİ"
        default:
            return "BEKLİYOR"
        }
    }
}
