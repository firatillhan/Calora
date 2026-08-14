//
//  KayitDetayView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct KayitDetayView: View {
    let kayit: Kayit

    var body: some View {
            Section {
                WebImage(url: resimURL) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 150, height: 150)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
            }
            
            List {
                Section("Bilgi") {
                    satir("İsim", kayit.isim)
                    satir("Miktar", String(format: "%.1f", kayit.miktar))
                }
                Section("Toplam Değerler") {
                    satir("Kalori", "\(kayit.toplamKalori) kcal")
                    satir("Protein", "\(String(format: "%.1f", kayit.toplamProtein)) g")
                    satir("Karbonhidrat", "\(String(format: "%.1f", kayit.toplamKarbonhidrat)) g")
                    satir("Yağ", "\(String(format: "%.1f", kayit.toplamYag)) g")
                    satir("Şeker", "\(String(format: "%.1f", kayit.toplamSeker)) g")
                    satir("Tuz", "\(String(format: "%.1f", kayit.toplamTuz)) g")
                }
            }
            .navigationTitle(kayit.isim)
            .navigationBarTitleDisplayMode(.inline)
        
    }

    private func satir(_ ad: String, _ deger: String) -> some View {
        HStack {
            Text(ad)
            Spacer()
            Text(deger)
                .foregroundStyle(.secondary)
        }
    }
    private var resimURL: URL? {
        guard let resim = kayit.resim else { return nil }
        let tam = BesinServisiGetir.resimTemelURL + resim
        return URL(string: tam)
    }
}

#Preview {
    KayitDetayView(kayit: Kayit(
        besinId: "1",
        isim: "Ceviz",
        birimKalori: 27,
        miktar: 5,
        tarih: Date(),
        protein: 0.6,
        karbonhidrat: 0.5,
        yag: 2.6,
        seker: 0.1,
        tuz: 0.0
    ))
}
