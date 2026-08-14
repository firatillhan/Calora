//
//  Config.swift
//  Calora
//
//  Created by Fırat İlhan on 14.08.2026.
//

import Foundation

enum Config {
    static var apiBaseURL: String {
        guard let yol = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            return ""
        }
        guard let sozluk = NSDictionary(contentsOfFile: yol) else {
            return ""
        }
        guard let taban = sozluk["ApiBaseURL"] as? String else {
            return ""
        }
        return taban
    }
}
