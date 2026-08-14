//
//  TakvimView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import Foundation
import SwiftUI

struct TakvimView: View {
    @Binding var seciliGun: Date
    @State private var gosterilenAy = Date()

    private let takvim = Calendar.current
    private let gunSimgeleri = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]
    var durum: (Date) -> Color?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button { ayDegistir(-1) } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(ayBasligi)
                    .font(.headline)
                Spacer()
                Button { ayDegistir(1) } label: {
                    Image(systemName: "chevron.right")
                }
            }

            HStack {
                ForEach(gunSimgeleri, id: \.self) { simge in
                    Text(simge)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            let sutunlar = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: sutunlar, spacing: 6) {
                ForEach(Array(gunleriUret().enumerated()), id: \.offset) { _, gun in
                    if let gun {
                        gunHucresi(gun)
                    } else {
                        Color.clear.frame(height: 40)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var ayBasligi: String {
        let bicimlendirici = DateFormatter()
        bicimlendirici.locale = Locale(identifier: "tr_TR")
        bicimlendirici.dateFormat = "LLLL yyyy"
        let sonuc = bicimlendirici.string(from: gosterilenAy).capitalized
        return sonuc
    }

    private func ayDegistir(_ fark: Int) {
        if let yeni = takvim.date(byAdding: .month, value: fark, to: gosterilenAy) {
            gosterilenAy = yeni
        }
    }

    private func gunleriUret() -> [Date?] {
        guard let aralik = takvim.dateInterval(of: .month, for: gosterilenAy),
              let ilkGun = takvim.dateComponents([.weekday], from: aralik.start).weekday else {
            return []
        }
        let pazartesiIndex = (ilkGun + 5) % 7
        var gunler: [Date?] = Array(repeating: nil, count: pazartesiIndex)
        var simdi = aralik.start
        while simdi < aralik.end {
            gunler.append(simdi)
            guard let sonraki = takvim.date(byAdding: .day, value: 1, to: simdi) else { break }
            simdi = sonraki
        }
        return gunler
    }

    @ViewBuilder
    private func gunHucresi(_ gun: Date) -> some View {
        let secili = takvim.isDate(gun, inSameDayAs: seciliGun)
        let bugun = takvim.isDateInToday(gun)
        Button {
            seciliGun = gun
        } label: {
            VStack(spacing: 4) {
                Text("\(takvim.component(.day, from: gun))")
                    .font(.subheadline)
                    .fontWeight(bugun ? .bold : .regular)
                    .foregroundStyle(secili ? .white : .primary)
                Circle()
                    .fill(durum(gun) ?? .clear)
                    .frame(width: 6, height: 6)
                    .opacity(durum(gun) == nil ? 0 : 1)
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .background(
                Circle()
                    .fill(secili ? Color.accentColor : Color.clear)
                    .padding(3)
            )
        }
        .buttonStyle(.plain)
    }
}
