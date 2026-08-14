//
//  ResimYardimci.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//


import UIKit

enum ResimYardimci {
    static func kucult(_ uiImage: UIImage) -> Data? {
        let sonuc = uiImage.jpegData(compressionQuality: 0.5)
        return sonuc
    }
}
