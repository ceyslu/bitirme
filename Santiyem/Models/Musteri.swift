import Foundation

struct Musteri: Codable, Identifiable {
    let id: Int
    let ad: String
    let telefon: String?
    let not: String?
    let olusturulmaTarihi: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ad = "name"
        case telefon = "phone"
        case not = "note"
        case olusturulmaTarihi = "created_at"
    }
}

struct MusteriDetay: Codable, Identifiable {
    let id: Int
    let ad: String
    let telefon: String?
    let not: String?
    let olusturulmaTarihi: String?
    let isler: [MusteriIsKaydi]

    enum CodingKeys: String, CodingKey {
        case id
        case ad = "name"
        case telefon = "phone"
        case not = "note"
        case olusturulmaTarihi = "created_at"
        case isler = "jobs"
    }
}

struct MusteriIsKaydi: Codable, Identifiable {
    let id: Int
    let isTarihi: String
    let calismaSuresi: Double
    let saatlikUcret: Double
    let yolUcreti: Double
    let toplamUcret: Double
    let odenenTutar: Double
    let odemeDurumu: String
    let not: String?
    let makineAdi: String?
    let isTuruAdi: String?

    var kalanTutar: Double {
        max(toplamUcret - odenenTutar, 0)
    }

    var toplamSaat: Double {
        calismaSuresi
    }

    enum CodingKeys: String, CodingKey {
        case id
        case isTarihi = "job_date"
        case calismaSuresi = "duration_hours"
        case saatlikUcret = "hourly_price"
        case yolUcreti = "road_fee"
        case toplamUcret = "total_price"
        case odenenTutar = "paid_amount"
        case odemeDurumu = "payment_status"
        case not = "notes"
        case makineAdi = "machine_name"
        case isTuruAdi = "job_type_name"
    }

    init(
        id: Int,
        isTarihi: String,
        calismaSuresi: Double,
        saatlikUcret: Double,
        yolUcreti: Double,
        toplamUcret: Double,
        odenenTutar: Double,
        odemeDurumu: String,
        not: String?,
        makineAdi: String?,
        isTuruAdi: String?
    ) {
        self.id = id
        self.isTarihi = isTarihi
        self.calismaSuresi = calismaSuresi
        self.saatlikUcret = saatlikUcret
        self.yolUcreti = yolUcreti
        self.toplamUcret = toplamUcret
        self.odenenTutar = odenenTutar
        self.odemeDurumu = odemeDurumu
        self.not = not
        self.makineAdi = makineAdi
        self.isTuruAdi = isTuruAdi
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        isTarihi = try container.decode(String.self, forKey: .isTarihi)
        odemeDurumu = try container.decode(String.self, forKey: .odemeDurumu)

        not = try? container.decode(String.self, forKey: .not)
        makineAdi = try? container.decode(String.self, forKey: .makineAdi)
        isTuruAdi = try? container.decode(String.self, forKey: .isTuruAdi)

        calismaSuresi = MusteriIsKaydi.decodeDouble(from: container, forKey: .calismaSuresi)
        saatlikUcret = MusteriIsKaydi.decodeDouble(from: container, forKey: .saatlikUcret)
        yolUcreti = MusteriIsKaydi.decodeDouble(from: container, forKey: .yolUcreti)
        toplamUcret = MusteriIsKaydi.decodeDouble(from: container, forKey: .toplamUcret)
        odenenTutar = MusteriIsKaydi.decodeDouble(from: container, forKey: .odenenTutar)
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

