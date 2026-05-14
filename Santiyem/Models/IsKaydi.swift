import Foundation

// Backend'den gelen iş kayıtlarını temsil eder
struct IsKaydi: Codable, Identifiable {
    let id: Int
    let isTuruId: Int
    let toplamUcret: Double
    let isTarihi: String

    enum CodingKeys: String, CodingKey {
        case id
        case isTuruId = "job_type_id"
        case toplamUcret = "total_price"
        case isTarihi = "job_date"
    }

    init(id: Int, isTuruId: Int, toplamUcret: Double, isTarihi: String) {
        self.id = id
        self.isTuruId = isTuruId
        self.toplamUcret = toplamUcret
        self.isTarihi = isTarihi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        isTuruId = try container.decode(Int.self, forKey: .isTuruId)
        isTarihi = try container.decode(String.self, forKey: .isTarihi)

        if let doubleValue = try? container.decode(Double.self, forKey: .toplamUcret) {
            toplamUcret = doubleValue
        } else if let intValue = try? container.decode(Int.self, forKey: .toplamUcret) {
            toplamUcret = Double(intValue)
        } else if let stringValue = try? container.decode(String.self, forKey: .toplamUcret),
                  let doubleValue = Double(stringValue) {
            toplamUcret = doubleValue
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .toplamUcret,
                in: container,
                debugDescription: "toplam ücret geçerli bir sayı değil"
            )
        }
    }
}

