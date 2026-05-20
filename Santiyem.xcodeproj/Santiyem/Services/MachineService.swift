import Foundation

struct MakineKayitIstek: Codable {
    let name: String
    let hourlyPrice: Double
    let isActive: Bool
}
struct MakineGuncelleIstek: Codable {
    let name: String
    let hourlyPrice: Double
    let isActive: Bool
}

final class MachineService {
    static let shared = MachineService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchMachines() async throws -> [Makine] {
        guard let url = URL(string: "\(baseURL)/api/machines") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([Makine].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Makineler alınamadı"
            ])
        }
    }
    func updateMachine(
        id: Int,
        name: String,
        hourlyPrice: Double,
        isActive: Bool
    ) async throws -> Makine {
        guard let url = URL(string: "\(baseURL)/api/machines/\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            MakineGuncelleIstek(
                name: name,
                hourlyPrice: hourlyPrice,
                isActive: isActive
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(Makine.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Makine güncellenemedi"
            ])
        }
    }

    
    
    func deleteMachine(id: Int) async throws {
        guard let url = URL(string: "\(baseURL)/api/machines/\(id)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if !(200 ... 299).contains(httpResponse.statusCode) {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Makine silinemedi"
            ])
        }
    }

    func createMachine(
        name: String,
        hourlyPrice: Double,
        isActive: Bool = true
    ) async throws -> Makine {
        guard let url = URL(string: "\(baseURL)/api/machines") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            MakineKayitIstek(
                name: name,
                hourlyPrice: hourlyPrice,
                isActive: isActive
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            if let jsonText = String(data: data, encoding: .utf8) {
                print("POST /api/machines response:", jsonText)
            }

            do {
                let machine = try JSONDecoder().decode(Makine.self, from: data)
                return machine
            } catch {
                print("Makine decode hatasi:", error)
                throw error
            }
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Makine eklenemedi"
            ])
        }
    }
}

