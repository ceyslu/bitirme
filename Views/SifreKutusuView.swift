import SwiftUI

struct SifreKutusuView: View {
    let index: Int
    let sifre: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .frame(width: 64, height: 74)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.45), lineWidth: 1.5)
                )

            if sifre.count > index {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 14, height: 14)
            }
        }
    }
}

#Preview {
    HStack {
        SifreKutusuView(index: 0, sifre: "12")
        SifreKutusuView(index: 1, sifre: "12")
        SifreKutusuView(index: 2, sifre: "12")
        SifreKutusuView(index: 3, sifre: "12")
    }
    .padding()
    .background(Color(.systemGray6))
}

