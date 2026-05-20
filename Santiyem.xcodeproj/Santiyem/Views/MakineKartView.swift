import SwiftUI

struct MakineKartView: View {
    
    let makine: Makine
    
    var body: some View {
        HStack(spacing: 14) {
            
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 245/255, green: 233/255, blue: 215/255))
                    .frame(width: 68, height: 68)
                
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color.orange)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(makine.ad.uppercased())
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color(red: 30/255, green: 40/255, blue: 70/255))
                    .lineLimit(1)
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(Int(makine.saatlikUcret)) ₺")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.orange)

                    Text("/ SAAT")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.gray)

                    Text(makine.aktifMi ? "AKTİF" : "PASİF")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            makine.aktifMi
                            ? Color.green.opacity(0.15)
                            : Color.red.opacity(0.15)
                        )
                        .foregroundColor(makine.aktifMi ? .green : .red)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
    }
}

#Preview {
    let ornekMakine = Makine(
        id: 1,
        ad: "JCB",
        saatlikUcret: 2250,
        aktifMi: true,
        olusturulmaTarihi: nil
    )

    return ZStack {
        Color(.systemGray6).ignoresSafeArea()
        MakineKartView(makine: ornekMakine)
            .padding()
    }
}

