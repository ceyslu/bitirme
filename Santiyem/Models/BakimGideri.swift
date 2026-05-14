import Foundation

struct BakimGideri: Codable, Identifiable {
    let id: Int
    let makineId: Int
    let islemAdi: String
    let tutar: Double
    let giderTarihi: String
    let olusturulmaTarihi: String?
    let makineAdi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case makineId = "machine_id"
        case islemAdi = "operation_name"
        case tutar = "cost"
        case giderTarihi = "expense_date"
        case olusturulmaTarihi = "created_at"
        case makineAdi = "machine_name"
    }

    init(
        id: Int,
        makineId: Int,
        islemAdi: String,
        tutar: Double,
        giderTarihi: String,
        olusturulmaTarihi: String?,
        makineAdi: String?
    ) {
        self.id = id
        self.makineId = makineId
        self.islemAdi = islemAdi
        self.tutar = tutar
        self.giderTarihi = giderTarihi
        self.olusturulmaTarihi = olusturulmaTarihi
        self.makineAdi = makineAdi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        makineId = try container.decode(Int.self, forKey: .makineId)
        islemAdi = try container.decode(String.self, forKey: .islemAdi)
        giderTarihi = try container.decode(String.self, forKey: .giderTarihi)
        olusturulmaTarihi = try? container.decode(String.self, forKey: .olusturulmaTarihi)
        makineAdi = try? container.decode(String.self, forKey: .makineAdi)

        if let doubleValue = try? container.decode(Double.self, forKey: .tutar) {
            tutar = doubleValue
        } else if let intValue = try? container.decode(Int.self, forKey: .tutar) {
            tutar = Double(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .tutar),
                  let doubleValue = Double(stringValue) {
            tutar = doubleValue
        } else {
            tutar = 0
        }
    }
}

