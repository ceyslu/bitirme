import Foundation

struct APIErrorResponse: Codable {
    let error: String
}

struct LoginRequest: Codable {
    let phone: String
    let pin: String
}

struct RegisterRequest: Codable {
    let companyName: String
    let fullName: String
    let phone: String
    let pin: String
}

struct ResetPinRequest: Codable {
    let phone: String
    let newPin: String
}

struct AuthUserResponse: Codable {
    let id: Int
    let companyName: String
    let fullName: String
    let phone: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case companyName = "company_name"
        case fullName = "full_name"
        case phone
        case createdAt = "created_at"
    }

    var kullanici: Kullanici {
        Kullanici(
            id: id,
            sirketAdi: companyName,
            adSoyad: fullName,
            telefon: phone,
            olusturulmaTarihi: createdAt
        )
    }
}

final class AuthService {
    static let shared = AuthService()

    private init() {}

    private let baseURL = "http://localhost:5001"

    func login(phone: String, pin: String) async throws -> AuthUserResponse {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            LoginRequest(phone: phone, pin: pin)
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeAuthResponse(data: data, response: response, fallback: "Giriş yapılamadı")
    }

    func register(
        companyName: String,
        fullName: String,
        phone: String,
        pin: String
    ) async throws -> AuthUserResponse {
        guard let url = URL(string: "\(baseURL)/api/auth/register") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            RegisterRequest(
                companyName: companyName,
                fullName: fullName,
                phone: phone,
                pin: pin
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        return try decodeAuthResponse(data: data, response: response, fallback: "Kayıt oluşturulamadı")
    }

    func resetPin(phone: String, newPin: String) async throws {
        guard let url = URL(string: "\(baseURL)/api/auth/reset-pin") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ResetPinRequest(phone: phone, newPin: newPin)
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
                NSLocalizedDescriptionKey: apiError?.error ?? "Şifre güncellenemedi"
            ])
        }
    }

    private func decodeAuthResponse(
        data: Data,
        response: URLResponse,
        fallback: String
    ) throws -> AuthUserResponse {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Sunucudan geçerli cevap alınamadı"
            ])
        }

        if 200 ... 299 ~= httpResponse.statusCode {
            return try JSONDecoder().decode(AuthUserResponse.self, from: data)
        } else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [
                NSLocalizedDescriptionKey: apiError?.error ?? fallback
            ])
        }
    }
}

