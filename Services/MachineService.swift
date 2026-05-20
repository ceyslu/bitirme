import Foundation

struct MakineKayitIstek: Codable {
    let userId: Int
    let name: String
    let hourlyPrice: Double
    let isActive: Bool
}

struct MakineGuncelleIstek: Codable {
    let userId: Int
    let name: String
    let hourlyPrice: Double
    let isActive: Bool
}

struct MakineDurumIstek: Codable {
    let userId: Int
    let isActive: Bool
}

final class MachineService {
    static let shared = MachineService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchMachines(userId: Int) async throws -> [Makine] {
        guard let url = URL(string: "\(baseURL)/api/machines?userId=\(userId)") else {
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

    func createMachine(
        userId: Int,
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
                userId: userId,
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
                NSLocalizedDescriptionKey: apiError?.error ?? "Makine eklenemedi"
            ])
        }
    }

    func updateMachine(
        userId: Int,
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
                userId: userId,
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

    func updateMachineStatus(
        userId: Int,
        id: Int,
        isActive: Bool
    ) async throws -> Makine {
        guard let url = URL(string: "\(baseURL)/api/machines/\(id)/status") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            MakineDurumIstek(
                userId: userId,
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
                NSLocalizedDescriptionKey: apiError?.error ?? "Makine durumu güncellenemedi"
            ])
        }
    }

    func deleteMachine(userId: Int, id: Int) async throws {
        guard let url = URL(string: "\(baseURL)/api/machines/\(id)?userId=\(userId)") else {
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
}

