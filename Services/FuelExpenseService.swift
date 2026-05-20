import Foundation

struct YakitGideriKayitIstek: Codable {
    let userId: Int
    let machineId: Int
    let cost: Double
    let liters: Double
    let expenseDate: String
}

final class FuelExpenseService {
    static let shared = FuelExpenseService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchFuelExpenses(userId: Int) async throws -> [YakitGideri] {
        guard let url = URL(string: "\(baseURL)/api/fuel-expenses?userId=\(userId)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([YakitGideri].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Yakıt giderleri alınamadı"
            ])
        }
    }

    func createFuelExpense(
        userId: Int,
        machineId: Int,
        cost: Double,
        liters: Double,
        expenseDate: String
    ) async throws -> YakitGideri {
        guard let url = URL(string: "\(baseURL)/api/fuel-expenses") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            YakitGideriKayitIstek(
                userId: userId,
                machineId: machineId,
                cost: cost,
                liters: liters,
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
            return try JSONDecoder().decode(YakitGideri.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Yakıt gideri eklenemedi"
            ])
        }
    }
}

