import Foundation

struct YakitGideri: Codable, Identifiable {
    let id: Int
    let makineId: Int
    let tutar: Double
    let litre: Double
    let giderTarihi: String
    let olusturulmaTarihi: String?
    let makineAdi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case makineId = "machine_id"
        case tutar = "cost"
        case litre = "liters"
        case giderTarihi = "expense_date"
        case olusturulmaTarihi = "created_at"
        case makineAdi = "machine_name"
    }

    init(
        id: Int,
        makineId: Int,
        tutar: Double,
        litre: Double,
        giderTarihi: String,
        olusturulmaTarihi: String?,
        makineAdi: String?
    ) {
        self.id = id
        self.makineId = makineId
        self.tutar = tutar
        self.litre = litre
        self.giderTarihi = giderTarihi
        self.olusturulmaTarihi = olusturulmaTarihi
        self.makineAdi = makineAdi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        makineId = try container.decode(Int.self, forKey: .makineId)
        giderTarihi = try container.decode(String.self, forKey: .giderTarihi)
        olusturulmaTarihi = try? container.decode(String.self, forKey: .olusturulmaTarihi)
        makineAdi = try? container.decode(String.self, forKey: .makineAdi)

        tutar = YakitGideri.decodeDouble(from: container, forKey: .tutar)
        litre = YakitGideri.decodeDouble(from: container, forKey: .litre)
    }

    private static func decodeDouble(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double {
        if let doubleValue = try? container.decode(Double.self, forKey: key) {
            return doubleValue
        } else if let intValue = try? container.decode(Int.self, forKey: key) {
            return Double(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: key),
                  let doubleValue = Double(stringValue) {
            return doubleValue
        } else {
            return 0
        }
    }
}

