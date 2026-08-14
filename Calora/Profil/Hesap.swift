//
//  Hesap.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import Foundation

struct ProfilSonuc {
    let bmr: Int
    let tdee: Int
    let kalori: Int
    let protein: Int
    let karbonhidrat: Int
    let yag: Int
    let idealAlt: Int
    let idealUst: Int
}

enum ProfilHesap {
    static func hesapla(boy: Double, kilo: Double, yas: Int, cinsiyet: String, aktiviteKatsayi: Double, hedef: String) -> ProfilSonuc {

        var bmr = 10 * kilo + 6.25 * boy - 5 * Double(yas)
        if cinsiyet == "erkek" {
            bmr += 5
        } else {
            bmr -= 161
        }

        let tdee = bmr * aktiviteKatsayi

        var kalori = tdee
        if hedef == "ver" {
            kalori = tdee - 500
        } else if hedef == "al" {
            kalori = tdee + 500
        }
        if kalori < 1200 {
            kalori = 1200
        }

        let proteinKcal = kalori * 0.30
        let karbKcal = kalori * 0.45
        let yagKcal = kalori * 0.25

        let protein = proteinKcal / 4
        let karbonhidrat = karbKcal / 4
        let yag = yagKcal / 9

        let boyMetre = boy / 100
        let idealAlt = 22 * boyMetre * boyMetre
        let idealUst = 24.9 * boyMetre * boyMetre

        let sonuc = ProfilSonuc(
            bmr: Int(bmr.rounded()),
            tdee: Int(tdee.rounded()),
            kalori: Int(kalori.rounded()),
            protein: Int(protein.rounded()),
            karbonhidrat: Int(karbonhidrat.rounded()),
            yag: Int(yag.rounded()),
            idealAlt: Int(idealAlt.rounded()),
            idealUst: Int(idealUst.rounded())
        )
        return sonuc
    }
}
