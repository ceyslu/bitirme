//
//  Kullanici.swift
//  Santiyem
//
//
//
import Foundation
import SwiftData

// Bu sınıf uygulamadaki kullanıcıları temsil eder.
// SwiftData sayesinde bu bilgiler iPhone içinde saklanır.

@Model
class Kullanici {
    
    // Kullanıcının şirket adı
    var sirketAdi: String
    
    // Kullanıcının adı soyadı
    var adSoyad: String
    
    // Kullanıcının telefon numarası
    var telefon: String
    
    // Kullanıcının 4 haneli şifresi
    var sifre: String
    
    // Kullanıcı oluşturulurken bu bilgiler girilir
    init(sirketAdi: String, adSoyad: String, telefon: String, sifre: String) {
        self.sirketAdi = sirketAdi
        self.adSoyad = adSoyad
        self.telefon = telefon
        self.sifre = sifre
    }
}
