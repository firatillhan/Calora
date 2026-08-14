//
//  BesinServisi.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//


import Foundation

enum BesinServisiGetir {
    
    static let resimTemelURL = "https://www.firatilhan.com.tr/dimg/calora/"
    
    static func besinGetir() async throws -> [Besin] {
        let adres = Config.apiBaseURL + "calora_list.php?action=calora_list"
        guard let url = URL(string: adres) else {
            throw URLError(.badURL)
        }

        let (veri, _) = try await URLSession.shared.data(from: url)

        let yanit = try JSONDecoder().decode(BesinYaniti.self, from: veri)
        return yanit.data
    }
    

}
