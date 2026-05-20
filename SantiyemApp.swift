import SwiftUI

@main
struct SantiyemApp: App {
    @StateObject private var oturum = OturumYonetici.shared

    var body: some Scene {
        WindowGroup {
            if oturum.girisYapildiMi {
                ContentView()
            } else {
                GirisView()
            }
        }
    }
}

