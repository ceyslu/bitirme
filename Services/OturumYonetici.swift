import Foundation
import SwiftUI
import Combine

@MainActor
final class OturumYonetici: ObservableObject {
    static let shared = OturumYonetici()

    @Published var aktifKullanici: Kullanici?

    private let kayitAnahtari = "aktif_kullanici"

    private init() {
        aktifKullaniciyiYukle()
    }

    var girisYapildiMi: Bool {
        aktifKullanici != nil
    }

    func kullaniciyiKaydet(_ kullanici: Kullanici) {
        aktifKullanici = kullanici

        if let data = try? JSONEncoder().encode(kullanici) {
            UserDefaults.standard.set(data, forKey: kayitAnahtari)
        }
    }

    func cikisYap() {
        aktifKullanici = nil
        UserDefaults.standard.removeObject(forKey: kayitAnahtari)
    }

    private func aktifKullaniciyiYukle() {
        guard let data = UserDefaults.standard.data(forKey: kayitAnahtari),
              let kullanici = try? JSONDecoder().decode(Kullanici.self, from: data) else {
            return
        }

        aktifKullanici = kullanici
    }
}

