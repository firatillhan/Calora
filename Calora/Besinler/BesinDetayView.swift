//
//  BesinDetayVie.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftData

struct BesinDetayView: View {
    let besin:Besin
    @State private var miktarText = ""
    @State private var uyariAcik = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack {
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        WebImage(url: resimURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("\(besin.kalori) kcal")
                    .font(.largeTitle.bold())
                
                
                HStack {
                    Text("Miktar")
                    Spacer()
                    TextField("1", text: $miktarText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                    Text(besin.porsiyonBirim ?? "")
                        .foregroundStyle(.secondary)
                }
                if let miktar = Double(miktarText.replacingOccurrences(of: ",", with: ".")), miktar > 0 {
                    VStack(spacing: 6) {
                        satirHesap("Kalori", "\(Int((Double(besin.kalori) * miktar).rounded())) kcal")
                        satirHesap("Protein", makroHesap(besin.protein, miktar))
                        satirHesap("Karbonhidrat", makroHesap(besin.karbonhidrat, miktar))
                        satirHesap("Şeker", makroHesap(besin.seker, miktar))
                        satirHesap("Yağ", makroHesap(besin.yag, miktar))
                        satirHesap("Tuz", makroHesap(besin.tuz, miktar))
                    }
                    .padding(.horizontal)
                }

                Button {
                    let miktar = Double(miktarText.replacingOccurrences(of: ",", with: ".")) ?? 0
                    if miktar <= 0 {
                        uyariAcik = true
                        return
                    }
                    kaydet(miktar)
                } label: {
                    Text("Yedim")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .alert("Miktar Gir", isPresented: $uyariAcik) {
                    Button("Tamam", role: .cancel) {}
                } message: {
                    Text("Lütfen geçerli bir miktar girin.")
                }
                
                
                
                
                metinSatiri("Porsiyon", porsiyonMetni)
                metinSatiri("Kategori", besin.kategori)
                makroSatiri("Protein", besin.protein)
                makroSatiri("Karbonhidrat", besin.karbonhidrat)
                makroSatiri("Şeker", besin.seker)
                makroSatiri("Yağ", besin.yag)
                makroSatiri("Tuz", besin.tuz)
                metinSatiri("Marka", besin.marka)
            }
            .padding()
        }
        .navigationTitle(besin.isim)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    BesinGuncelleView(besin: besin)
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
    }
    
    private var resimURL: URL? {
        guard let resim = besin.resim else {
            return nil
        }
        let tam = BesinServisiGetir.resimTemelURL + resim
        return URL(string: tam)
    }
    private func makroSatiri(_ ad: String, _ deger: Double?) -> some View {
        HStack {
            Text(ad)
            Spacer()
            if let deger {
                Text("\(deger, specifier: "%.1f") g")
                    .fontWeight(.semibold)
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
    
    private var porsiyonMetni: String? {
        guard let miktar = besin.porsiyonMiktar, let birim = besin.porsiyonBirim else {
            return nil
        }
        let sonuc = "\(miktar) \(birim)"
        return sonuc
    }
    
    
    @ViewBuilder
    private func metinSatiri(_ ad: String, _ deger: String?) -> some View {
        HStack {
            Text(ad)
            Spacer()
            if let deger, !deger.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(deger)
                    .fontWeight(.semibold)
            } else {
                Text("—")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
    private func satirHesap(_ ad: String, _ deger: String) -> some View {
        HStack {
            Text(ad).font(.caption)
            Spacer()
            Text(deger).font(.caption.bold())
        }
    }

    private func makroHesap(_ birim: Double?, _ miktar: Double) -> String {
        guard let birim else { return "—" }
        let toplam = birim * miktar
        return "\(String(format: "%.1f", toplam)) g"
    }
    private func kaydet(_ miktar: Double) {

        let kayit = Kayit(besinId: besin.id, isim: besin.isim, birimKalori: besin.kalori, miktar: miktar, tarih: Date(), protein: besin.protein, karbonhidrat: besin.karbonhidrat, yag: besin.yag, seker: besin.seker, tuz: besin.tuz,resim: besin.resim)
        modelContext.insert(kayit)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    BesinDetayView(besin: Besin(
        id: "1",
        isim: "Ayran",
        kalori: 80,
        porsiyonBirim: "adet",
        porsiyonMiktar: 1,
        resim: "ayran.jpg",
        protein: 3.5,
        karbonhidrat: 4.0,
        seker: 4.0,
        yag: 1.5,
        marka: "Pınar",
        kategori: "Süt Ürünü",
        tuz: 0.3
    ))
}
