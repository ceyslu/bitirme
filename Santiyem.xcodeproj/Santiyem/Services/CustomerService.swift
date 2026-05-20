import Foundation

struct MusteriKayitIstek: Codable {
    let name: String
    let phone: String
    let note: String
}

final class CustomerService {
    static let shared = CustomerService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    // Tüm müşterileri getirir
    func fetchCustomers() async throws -> [Musteri] {
        guard let url = URL(string: "\(baseURL)/api/customers") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([Musteri].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Müşteriler alınamadı"
            ])
        }
    }

    // Tek müşterinin detayını ve ona ait işleri getirir
    func fetchCustomerDetail(id: Int) async throws -> MusteriDetay {
        guard let url = URL(string: "\(baseURL)/api/customers/\(id)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(MusteriDetay.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Müşteri detayı alınamadı"
            ])
        }
    }

    // Yeni müşteri ekler
    func createCustomer(name: String, phone: String, note: String) async throws -> Musteri {
        guard let url = URL(string: "\(baseURL)/api/customers") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            MusteriKayitIstek(
                name: name,
                phone: phone,
                note: note
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(Musteri.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Müşteri eklenemedi"
            ])
        }
    }
}

