//
//  BesinServisiGuncelle.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import Foundation

enum BesinServisiGuncelle  {
    
    static func besinGuncelle(
        id: String,
        isim: String,
        kalori: Int,
        porsiyonBirim: String,
        porsiyonMiktar: Double?,
        protein: Double?,
        karbonhidrat: Double?,
        seker: Double?,
        yag: Double?,
        tuz: Double?,
        marka: String,
        kategori: String,
        fotoData: Data?
    ) async throws -> Bool {
        let adres = Config.apiBaseURL + "calora_list.php?action=besin_guncelle"
        guard let url = URL(string: adres) else {
            throw URLError(.badURL)
        }

        let sinir = "Sinir-\(UUID().uuidString)"
        var istek = URLRequest(url: url)
        istek.httpMethod = "POST"
        istek.setValue("multipart/form-data; boundary=\(sinir)", forHTTPHeaderField: "Content-Type")

        var govde = Data()

        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "id", deger: id))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "isim", deger: isim))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "kalori", deger: "\(kalori)"))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "porsiyonBirim", deger: porsiyonBirim))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "porsiyonMiktar", deger: MultipartYardimci.makroMetin(porsiyonMiktar)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "protein", deger: MultipartYardimci.makroMetin(protein)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "karbonhidrat", deger: MultipartYardimci.makroMetin(karbonhidrat)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "seker", deger: MultipartYardimci.makroMetin(seker)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "yag", deger: MultipartYardimci.makroMetin(yag)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "tuz", deger: MultipartYardimci.makroMetin(tuz)))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "marka", deger: marka))
        govde.append(MultipartYardimci.alanEkle(sinir: sinir, ad: "kategori", deger: kategori))

        if let fotoData {
            govde.append(MultipartYardimci.dosyaEkle(sinir: sinir, ad: "resim", dosyaAdi: "foto.jpg", veri: fotoData))
        }

        let kapanis = "--\(sinir)--\r\n"
        govde.append(Data(kapanis.utf8))

        istek.httpBody = govde

        let (veri, _) = try await URLSession.shared.data(for: istek)


        let yanit = try JSONDecoder().decode(EkleYaniti.self, from: veri)
        return yanit.success
    }
    
}
