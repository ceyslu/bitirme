//
//  MusteriDetayView 2.swift
//  Santiyem
//
//  Created by Ceyda Uslu on 23.04.2026.
//


import SwiftUI

struct MusteriDetayView: View {
    let musteriId: Int

    @Environment(\.dismiss) private var dismiss

    @State private var musteriDetay: MusteriDetay?
    @State private var yukleniyor = false
    @State private var hataMesaji = ""

    @State private var secilenIs: MusteriIsKaydi?
    @State private var odemeSecimAcik = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                if yukleniyor {
                    ProgressView("Müşteri bilgileri yükleniyor...")
                } else if !hataMesaji.isEmpty {
                    Text(hataMesaji)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                } else if let musteriDetay {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 22) {
                            ustAlan(musteriDetay)

                            ozetKartlar(musteriDetay)

                            yeniIsButonu

                            Text("HESAP HAREKETLERİ")
                                .font(.system(size: 16, weight: .heavy))
                                .italic()
                                .tracking(3)
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.horizontal, 20)

                            VStack(spacing: 16) {
                                ForEach(musteriDetay.isler) { isKaydi in
                                    isKart(isKaydi)
                                        .onTapGesture {
                                            secilenIs = isKaydi
                                            odemeSecimAcik = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)

                            Spacer(minLength: 30)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .confirmationDialog(
                "Ödeme durumu seçin",
                isPresented: $odemeSecimAcik,
                titleVisibility: .visible
            ) {
                Button("Ödendi") {
                    Task { await odemeDurumuGuncelle("odendi") }
                }
                Button("Kısmi") {
                    Task { await odemeDurumuGuncelle("kismi") }
                }
                Button("Bekliyor") {
                    Task { await odemeDurumuGuncelle("bekliyor") }
                }
                Button("Vazgeç", role: .cancel) { }
            }
            .task {
                await detayiYukle()
            }
        }
    }

    private func ustAlan(_ musteri: MusteriDetay) -> some View {
        HStack(alignment: .center) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 58, height: 58)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)

                    Image(systemName: "arrow.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(musteri.ad.uppercased())
                    .font(.system(size: 30, weight: .heavy))
                    .italic()
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                Text((musteri.not ?? "").uppercased())
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.orange)
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.green.opacity(0.10))
                    .frame(width: 72, height: 72)

                Image(systemName: "phone")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 20)
    }

    private func ozetKartlar(_ musteri: MusteriDetay) -> some View {
        let toplamCiro = musteri.isler.reduce(0) { $0 + $1.toplamUcret }
        let kalanAlacak = musteri.isler
            .filter { $0.odemeDurumu != "odendi" }
            .reduce(0) { $0 + $1.toplamUcret }

        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("TOPLAM CİRO")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.gray.opacity(0.8))

                Text("\(Int(toplamCiro)) ₺")
                    .font(.system(size: 28, weight: .heavy))
                    .italic()
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 12) {
                Text("KALAN ALACAK")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(.gray.opacity(0.8))

                Text("\(Int(kalanAlacak)) ₺")
                    .font(.system(size: 28, weight: .heavy))
                    .italic()
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.red.opacity(0.7), lineWidth: 4)
                    .offset(y: 2)
                    .mask(
                        RoundedRectangle(cornerRadius: 28)
                            .padding(.top, 26)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
    }

    private var yeniIsButonu: some View {
        Button {
            // Sonraki adımda gerçek iş ekleme ekranına bağlayacağız
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus")
                    .font(.system(size: 26, weight: .bold))

                Text("YENİ İŞ BAŞLAT")
                    .font(.system(size: 24, weight: .heavy))
                    .italic()
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(Color.orange)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: Color.orange.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .padding(.horizontal, 20)
    }

    private func isKart(_ isKaydi: MusteriIsKaydi) -> some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(renkArkaPlan(isKaydi.odemeDurumu))
                    .frame(width: 84, height: 84)

                Image(systemName: ikonAdi(isKaydi.odemeDurumu))
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(ikonRenk(isKaydi.odemeDurumu))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text((isKaydi.isTuruAdi ?? "İŞ KAYDI").uppercased())
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                Text("\(formatTarih(isKaydi.isTarihi)) • \((isKaydi.makineAdi ?? "-").uppercased())")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray.opacity(0.8))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("\(Int(isKaydi.toplamUcret)) ₺")
                    .font(.system(size: 22, weight: .heavy))
                    .italic()
                    .foregroundColor(Color(red: 35/255, green: 47/255, blue: 74/255))

                Text(odemeDurumuMetni(isKaydi.odemeDurumu))
                    .font(.system(size: 14, weight: .heavy))
                    .tracking(2)
                    .foregroundColor(.gray.opacity(0.8))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    @MainActor
    private func detayiYukle() async {
        yukleniyor = true
        hataMesaji = ""

        defer { yukleniyor = false }

        do {
            musteriDetay = try await CustomerService.shared.fetchCustomerDetail(id: musteriId)
        } catch {
            hataMesaji = error.localizedDescription
        }
    }

    @MainActor
    private func odemeDurumuGuncelle(_ yeniDurum: String) async {
        guard let secilenIs else { return }

        do {
            _ = try await JobService.shared.updatePaymentStatus(
                jobId: secilenIs.id,
                paymentStatus: yeniDurum
            )
            await detayiYukle()
        } catch {
            hataMesaji = error.localizedDescription
        }
    }

    private func formatTarih(_ tarihMetni: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "tr_TR")
        displayFormatter.dateFormat = "dd.MM.yyyy"

        if let date = isoFormatter.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        let fallback = ISO8601DateFormatter()
        fallback.formatOptions = [.withInternetDateTime]

        if let date = fallback.date(from: tarihMetni) {
            return displayFormatter.string(from: date)
        }

        return tarihMetni
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

    private func ikonAdi(_ durum: String) -> String {
        switch durum {
        case "odendi":
            return "checkmark.circle"
        case "kismi":
            return "clock"
        default:
            return "exclamationmark.circle"
        }
    }

    private func ikonRenk(_ durum: String) -> Color {
        switch durum {
        case "odendi":
            return .green
        case "kismi":
            return .indigo
        default:
            return .orange
        }
    }

    private func renkArkaPlan(_ durum: String) -> Color {
        switch durum {
        case "odendi":
            return Color.green.opacity(0.12)
        case "kismi":
            return Color.indigo.opacity(0.12)
        default:
            return Color.orange.opacity(0.12)
        }
    }
}

#Preview {
    MusteriDetayView(musteriId: 1)
}
