//
//  MultipartYardimci.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import Foundation

import Foundation

enum MultipartYardimci {
    static func alanEkle(sinir: String, ad: String, deger: String) -> Data {
        var parca = ""
        parca += "--\(sinir)\r\n"
        parca += "Content-Disposition: form-data; name=\"\(ad)\"\r\n\r\n"
        parca += "\(deger)\r\n"
        let sonuc = Data(parca.utf8)
        return sonuc
    }

    static func dosyaEkle(sinir: String, ad: String, dosyaAdi: String, veri: Data) -> Data {
        var parca = Data()
        var bas = ""
        bas += "--\(sinir)\r\n"
        bas += "Content-Disposition: form-data; name=\"\(ad)\"; filename=\"\(dosyaAdi)\"\r\n"
        bas += "Content-Type: image/jpeg\r\n\r\n"
        parca.append(Data(bas.utf8))
        parca.append(veri)
        parca.append(Data("\r\n".utf8))
        return parca
    }

    static func makroMetin(_ deger: Double?) -> String {
        guard let deger else {
            return ""
        }
        let sonuc = "\(deger)"
        return sonuc
    }
}
