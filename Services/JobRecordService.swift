import Foundation

final class JobRecordService {
    static let shared = JobRecordService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func fetchJobRecords(userId: Int) async throws -> [IsKaydi] {
        guard let url = URL(string: "\(baseURL)/api/jobs?userId=\(userId)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode([IsKaydi].self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "İş kayıtları alınamadı"
            ])
        }
    }
}

