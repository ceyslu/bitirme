import Foundation

// Backend'den gelen iş türü modeli
struct IsTuru: Codable, Identifiable {
    let id: Int
    let ad: String
    let olusturulmaTarihi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ad = "name"
        case olusturulmaTarihi = "created_at"
    }
}

