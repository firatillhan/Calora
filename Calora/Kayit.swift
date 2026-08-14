//
//  Kayit.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//
import Foundation
import SwiftData

@Model
class Kayit {
    var id: UUID = UUID()
    var besinId: String
    var isim: String
    var birimKalori: Int
    var miktar: Double
    var tarih: Date
    var protein: Double?
    var karbonhidrat: Double?
    var yag: Double?
    var seker: Double?
    var tuz: Double?
    var resim: String?

    init(besinId: String, isim: String, birimKalori: Int, miktar: Double, tarih: Date = Date(), protein: Double? = nil, karbonhidrat: Double? = nil, yag: Double? = nil,seker: Double? = nil, tuz: Double? = nil,resim: String? = nil) {
        self.besinId = besinId
        self.isim = isim
        self.birimKalori = birimKalori
        self.miktar = miktar
        self.tarih = tarih
        self.protein = protein
        self.karbonhidrat = karbonhidrat
        self.yag = yag
        self.seker = seker
        self.tuz = tuz
        self.resim = resim
    }
    
    
    var toplamKalori: Int {
        let sonuc = Double(birimKalori) * miktar
        return Int(sonuc.rounded())
    }
    var toplamProtein: Double {
        let sonuc = (protein ?? 0) * miktar
        return sonuc
    }
    var toplamKarbonhidrat: Double {
        let sonuc = (karbonhidrat ?? 0) * miktar
        return sonuc
    }
    var toplamYag: Double {
        let sonuc = (yag ?? 0) * miktar
        return sonuc
    }
    
    var toplamSeker: Double {
        let sonuc = (seker ?? 0) * miktar
        return sonuc
    }
    var toplamTuz: Double {
        let sonuc = (tuz ?? 0) * miktar
        return sonuc
    }
    
}
