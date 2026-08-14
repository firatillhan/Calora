//
//  BesinYaniti.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//


import Foundation

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
    let barkod: String?
    let kategori: String?
    let tuz: Double?
}


struct EkleYaniti: Codable {
    let success: Bool
    let id: String?
    let resim: String?
}
