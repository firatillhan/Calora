//
//  GunlukHedef.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//
import Foundation
import SwiftData

@Model
class GunlukHedef {
    var gun: Date
    var hedefKalori: Int
    var yakilanKalori: Int

    init(gun: Date, hedefKalori: Int, yakilanKalori: Int = 0) {
        self.gun = Calendar.current.startOfDay(for: gun)
        self.hedefKalori = hedefKalori
        self.yakilanKalori = yakilanKalori
    }
}

