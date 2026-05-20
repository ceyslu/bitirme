import Foundation

struct OdemeDurumuGuncelleIstek: Codable {
    let userId: Int
    let paymentStatus: String
    let paidAmount: Double
}

struct IsKaydiKayitIstek: Codable {
    let userId: Int
    let customerId: Int
    let machineId: Int
    let jobTypeId: Int
    let jobDate: String
    let durationHours: Double
    let hourlyPrice: Double
    let roadFee: Double
    let totalPrice: Double
    let paymentStatus: String
    let notes: String
}

final class JobService {
    static let shared = JobService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func createJob(
        userId: Int,
        customerId: Int,
        machineId: Int,
        jobTypeId: Int,
        jobDate: String,
        durationHours: Double,
        hourlyPrice: Double,
        roadFee: Double,
        totalPrice: Double,
        paymentStatus: String,
        notes: String
    ) async throws {
        guard let url = URL(string: "\(baseURL)/api/jobs") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            IsKaydiKayitIstek(
                userId: userId,
                customerId: customerId,
                machineId: machineId,
                jobTypeId: jobTypeId,
                jobDate: jobDate,
                durationHours: durationHours,
                hourlyPrice: hourlyPrice,
                roadFee: roadFee,
                totalPrice: totalPrice,
                paymentStatus: paymentStatus,
                notes: notes
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if !(200 ... 299).contains(httpResponse.statusCode) {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "İş kaydı eklenemedi"
            ])
        }
    }

    func updatePaymentStatus(
        userId: Int,
        jobId: Int,
        paymentStatus: String,
        paidAmount: Double
    ) async throws -> MusteriIsKaydi {
        guard let url = URL(string: "\(baseURL)/api/jobs/\(jobId)/payment-status") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            OdemeDurumuGuncelleIstek(
                userId: userId,
                paymentStatus: paymentStatus,
                paidAmount: paidAmount
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(MusteriIsKaydi.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? "Ödeme durumu güncellenemedi"
            ])
        }
    }
}

