//
//  ProfilView.swift
//  Santiyem
//

import SwiftUI

// Bu ekran şirket profilinin tutulacağı sayfadır.
// İleride burada:
// - şirket adı
// - yetkili adı
// - telefon
// - e-posta
// gibi bilgiler yer alacak.

struct ProfilView: View {
    
    var body: some View {
        
        NavigationStack {
            Text("Profil Sayfası")
                .font(.title)
                .navigationTitle("Profil")
        }
        
    }
}

#Preview {
    ProfilView()
}
