//
//  BesinYaniti.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//


import Foundation
import FoundationModels

struct BesinYaniti: Codable {
    let success: Bool
    let data: [Besin]
}

struct Besin: Codable, Identifiable {
    let id: String
    let isim: String
    let kalori: Int
    let porsiyonBirim: String?
    let porsiyonMiktar: Double?
    let resim: String?
    let protein: Double?
    let karbonhidrat: Double?
    let seker: Double?
    let yag: Double?
    let marka: String?
    let kategori: String?
    let tuz: Double?
}


struct EkleYaniti: Codable {
    let success: Bool
    let id: String?
    let resim: String?
}

@available(iOS 26, *)
@Generable
struct BesinBilgisiAI {
    @Guide(description: "Besinin veya yemeğin ismi")
    let isim: String

    @Guide(description: "Tahmini kalori değeri (kcal)")
    let kalori: Int

    @Guide(description: "Tahmini protein miktarı (gram)")
    let protein: Double

    @Guide(description: "Tahmini yağ miktarı (gram)")
    let yag: Double

    @Guide(description: "Tahmini karbonhidrat miktarı (gram)")
    let karbonhidrat: Double

    @Guide(description: "Tahmini şeker miktarı (gram)")
    let seker: Double

    @Guide(description: "Tahmini tuz miktarı (gram)")
    let tuz: Double
}
