import Foundation

enum PanoFiltre: String, CaseIterable, Identifiable {
    case haftalik = "Haftalık"
    case aylik = "Aylık"

    var id: String { rawValue }
}

struct PanoGrafikNoktasi: Identifiable {
    let id = UUID()
    let baslik: String
    let gelir: Double
    let gider: Double
}

struct PanoGiderSatiri: Identifiable {
    let id: String
    let tur: String
    let baslik: String
    let altBaslik: String
    let tutar: Double
    let tarih: Date
}

struct PanoGelirSatiri: Identifiable {
    let id: Int
    let sirketAdi: String
    let isTuru: String
    let alinanTutar: Double
    let isToplami: Double
    let tarih: Date
    let odemeAciklamasi: String
}

struct PanoSonIslem: Identifiable {
    let id: String
    let tur: String
    let baslik: String
    let altBaslik: String
    let tutar: Double
    let tarih: Date
}

struct PanoOzet {
    let toplamGelir: Double
    let toplamGider: Double
    let netKar: Double
    let bekleyenOdemeTutari: Double
    let grafik: [PanoGrafikNoktasi]
    let gelirKayitlari: [PanoGelirSatiri]
    let giderKayitlari: [PanoGiderSatiri]
    let sonIslemler: [PanoSonIslem]
}


struct PanoIsKaydi: Codable, Identifiable {
    let id: Int
    let jobDate: String
    let totalPrice: Double
    let paidAmount: Double
    let customerName: String?
    let jobTypeName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case jobDate = "job_date"
        case totalPrice = "total_price"
        case paidAmount = "paid_amount"
        case customerName = "customer_name"
        case jobTypeName = "job_type_name"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decode(Int.self, forKey: .id)
        jobDate = try c.decode(String.self, forKey: .jobDate)
        customerName = try? c.decode(String.self, forKey: .customerName)
        jobTypeName = try? c.decode(String.self, forKey: .jobTypeName)

        if let d = try? c.decode(Double.self, forKey: .totalPrice) {
            totalPrice = d
        } else if let i = try? c.decode(Int.self, forKey: .totalPrice) {
            totalPrice = Double(i)
        } else if let s = try? c.decode(String.self, forKey: .totalPrice),
                  let d = Double(s) {
            totalPrice = d
        } else {
            totalPrice = 0
        }

        if let d = try? c.decode(Double.self, forKey: .paidAmount) {
            paidAmount = d
        } else if let i = try? c.decode(Int.self, forKey: .paidAmount) {
            paidAmount = Double(i)
        } else if let s = try? c.decode(String.self, forKey: .paidAmount),
                  let d = Double(s) {
            paidAmount = d
        } else {
            paidAmount = 0
        }
    }
}

