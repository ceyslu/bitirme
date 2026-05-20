//
//  ContentView.swift
//  Santiyem
//
//  Created by Ceyda Uslu on 11.03.2026.
//
import SwiftUI

// Bu ekran uygulamanın ana ekranıdır.
// Uygulama açıldığında ilk çalışan View budur.

struct ContentView: View {
    
    var body: some View {
        
        // TabView iOS'ta alttaki sekmeli menüyü oluşturur
        TabView {
            
            // Panolar ekranı
            PanolarView()
                .tabItem {
                    // Menüde görünen isim ve ikon
                    Label("Panolar", systemImage: "chart.bar")
                }
            
            // Makineler ekranı
            MakinelerView()
                .tabItem {
                    Label("Makineler", systemImage: "wrench.and.screwdriver")
                }
            
            // Müşteriler ekranı
            MusterilerView()
                .tabItem {
                    Label("Müşteriler", systemImage: "person.3")
                }
            
            // Yapılan işler ekranı
            IslerView()
                .tabItem {
                    Label("İşler", systemImage: "list.bullet.clipboard")
                }
            
        }
        
    }
}

// Xcode Preview için kullanılır
#Preview {
    ContentView()
}
