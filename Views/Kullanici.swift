import Foundation

struct Kullanici: Codable, Identifiable {
    let id: Int
    let sirketAdi: String
    let adSoyad: String
    let telefon: String
    let olusturulmaTarihi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sirketAdi = "company_name"
        case adSoyad = "full_name"
        case telefon = "phone"
        case olusturulmaTarihi = "created_at"
    }
}

