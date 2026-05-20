//
//  SifreKutusuView.swift
//  Santiyem
//
//  
//

import SwiftUI

// Bu küçük görünüm giriş ekranındaki 4 PIN kutusunu oluşturur.
// Kullanıcı sayı girdikçe kutular dolu görünür.

struct SifreKutusuView: View {
    
    let index: Int
    let sifre: String
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange, lineWidth: 2)
                .frame(width: 60, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.08))
                )
            
            // Eğer bu indexte karakter varsa turuncu nokta göster
            if sifre.count > index {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 14, height: 14)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 14, height: 14)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            SifreKutusuView(index: 0, sifre: "12")
            SifreKutusuView(index: 1, sifre: "12")
            SifreKutusuView(index: 2, sifre: "12")
            SifreKutusuView(index: 3, sifre: "12")
        }
    }
}
