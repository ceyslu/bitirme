//
//  SifremiUnuttumView.swift
//  Santiyem
//
//  
//

import SwiftUI
import SwiftData

// Bu ekran şifre unutma işlemi için kullanılır.
// Kullanıcı telefon numarasını girer.
// Eğer telefon numarası sistemde varsa yeni 4 haneli şifre belirleyebilir.

struct SifremiUnuttumView: View {
    
    // Veri tabanı bağlantısı
    @Environment(\.modelContext) private var context
    
    // Kayıtlı kullanıcıları getirir
    @Query var kullanicilar: [Kullanici]
    
    // Ekranı kapatmak için kullanılır
    @Environment(\.dismiss) var dismiss
    
    // Form alanları
    @State private var telefon: String = ""
    @State private var yeniSifre: String = ""
    
    // Kullanıcıya mesaj göstermek için
    @State private var mesaj: String = ""
    
    var body: some View {
        
        ZStack {
            
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 22) {
                
                Spacer()
                
                VStack(spacing: 10) {
                    Text("Şifremi Unuttum")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.orange)
                    
                    Text("Telefon numaranızı ve yeni 4 haneli şifrenizi girin")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Telefon alanı
                TextField("Telefon Numarası", text: $telefon)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)
                    .onChange(of: telefon) { _, yeniDeger in
                        
                        // Sadece rakam kabul et
                        let sadeceRakam = yeniDeger.filter { $0.isNumber }
                        
                        // En fazla 11 hane
                        if sadeceRakam.count <= 11 {
                            telefon = sadeceRakam
                        } else {
                            telefon = String(sadeceRakam.prefix(11))
                        }
                    }
                
                // Yeni şifre alanı
                SecureField("Yeni 4 Haneli Şifre", text: $yeniSifre)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 30)
                    .onChange(of: yeniSifre) { _, yeniDeger in
                        
                        // Sadece rakam kabul et
                        let sadeceRakam = yeniDeger.filter { $0.isNumber }
                        
                        // Şifre en fazla 4 hane
                        if sadeceRakam.count <= 4 {
                            yeniSifre = sadeceRakam
                        } else {
                            yeniSifre = String(sadeceRakam.prefix(4))
                        }
                    }
                
                // Bilgi / hata mesajı
                if !mesaj.isEmpty {
                    Text(mesaj)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Şifre sıfırlama butonu
                Button {
                    
                    // Alan kontrolü
                    if telefon.count < 10 || yeniSifre.count != 4 {
                        mesaj = "Lütfen telefon ve yeni şifre alanlarını doğru doldurun."
                        return
                    }
                    
                    // Telefon numarasına göre kullanıcıyı bul
                    if let kullanici = kullanicilar.first(where: { $0.telefon == telefon }) {
                        
                        // Şifreyi güncelle
                        kullanici.sifre = yeniSifre
                        
                        do {
                            // Güncellenen şifreyi gerçekten kaydet
                            try context.save()
                            
                            // Başarılıysa giriş ekranına dön
                            dismiss()
                        } catch {
                            mesaj = "Şifre güncellenirken hata oluştu."
                        }
                        
                    } else {
                        mesaj = "Bu telefon numarası ile kayıtlı kullanıcı bulunamadı."
                    }
                    
                } label: {
                    Text("Şifreyi Güncelle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                        .padding(.horizontal, 30)
                }
                Spacer()
            }
        }
        .navigationTitle("Şifre")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SifremiUnuttumView()
    }
}
