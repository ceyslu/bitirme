import Foundation

struct Makine: Codable, Identifiable {
    let id: Int
    let ad: String
    let saatlikUcret: Double
    let aktifMi: Bool
    let olusturulmaTarihi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ad = "name"
        case saatlikUcret = "hourly_price"
        case aktifMi = "is_active"
        case olusturulmaTarihi = "created_at"
    }

    init(
        id: Int,
        ad: String,
        saatlikUcret: Double,
        aktifMi: Bool,
        olusturulmaTarihi: String?
    ) {
        self.id = id
        self.ad = ad
        self.saatlikUcret = saatlikUcret
        self.aktifMi = aktifMi
        self.olusturulmaTarihi = olusturulmaTarihi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        ad = try container.decode(String.self, forKey: .ad)
        aktifMi = try container.decode(Bool.self, forKey: .aktifMi)
        olusturulmaTarihi = try? container.decode(String.self, forKey: .olusturulmaTarihi)

        if let doubleValue = try? container.decode(Double.self, forKey: .saatlikUcret) {
            saatlikUcret = doubleValue
        } else if let intValue = try? container.decode(Int.self, forKey: .saatlikUcret) {
            saatlikUcret = Double(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .saatlikUcret),
                  let doubleValue = Double(stringValue) {
            saatlikUcret = doubleValue
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .saatlikUcret,
                in: container,
                debugDescription: "hourly_price geçerli bir sayı değil"
            )
        }
    }
}

