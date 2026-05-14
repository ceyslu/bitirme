import Foundation

struct BakimGideriIstek: Codable {
    let machineId: Int
    let operationName: String
    let cost: Double
    let expenseDate: String
}

final class BakimGideriService {
    static let shared = BakimGideriService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchMaintenanceExpenses() async throws -> [BakimGideri] {
        guard let url = URL(string: "\(baseURL)/api/maintenance-expenses") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([BakimGideri].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Bakım giderleri alınamadı"
            ])
        }
    }

    func createMaintenanceExpense(
        machineId: Int,
        operationName: String,
        cost: Double,
        expenseDate: String
    ) async throws -> BakimGideri {
        guard let url = URL(string: "\(baseURL)/api/maintenance-expenses") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            BakimGideriIstek(
                machineId: machineId,
                operationName: operationName,
                cost: cost,
                expenseDate: expenseDate
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(BakimGideri.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Bakım gideri eklenemedi"
            ])
        }
    }
}

