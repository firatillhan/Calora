//
//  BesinGuncelleView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct BesinGuncelleView: View {
    @Environment(\.dismiss) private var dismiss
    let besin: Besin

    @State private var isim = ""
    @State private var kaloriText = ""
    @State private var miktarText = ""
    @State private var porsiyonBirim = "adet"
    @State private var proteinText = ""
    @State private var karbonhidratText = ""
    @State private var sekerText = ""
    @State private var yagText = ""
    @State private var tuzText = ""
    @State private var markaText = ""
    @State private var barkodText = ""
    @State private var kategoriText = ""

    @State private var secilenFoto: PhotosPickerItem?
    @State private var fotoData: Data?
    @State private var kaydediliyor = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if let fotoData, let uiImage = UIImage(data: fotoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else if let resim = besin.resim {
                        WebImage(url: URL(string: BesinServisiGetir.resimTemelURL + resim)) { image in
                            image.resizable()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                        .scaledToFill()
                        .aspectRatio(1, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    PhotosPicker(selection: $secilenFoto, matching: .images) {
                        Text("Fotoğrafı değiştirmek için tıklayın")
                    }
                    .onChange(of: secilenFoto) { _, yeni in
                        Task {
                            fotoData = try? await yeni?.loadTransferable(type: Data.self)
                        }
                    }
                }

                Section("Bilgiler") {
                    HStack {
                        Text("İsim")
                        Spacer()
                        TextField("", text: $isim)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kalori")
                        Spacer()
                        TextField("", text: $kaloriText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Miktar")
                        Spacer()
                        TextField("", text: $miktarText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Birim", selection: $porsiyonBirim) {
                        Text("Adet").tag("adet")
                        Text("Gram").tag("gram")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Makrolar") {
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Karbonhidrat")
                        Spacer()
                        TextField("0", text: $karbonhidratText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Şeker")
                        Spacer()
                        TextField("0", text: $sekerText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Yağ")
                        Spacer()
                        TextField("0", text: $yagText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Tuz")
                        Spacer()
                        TextField("0", text: $tuzText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Diğer") {
                    HStack {
                        Text("Marka")
                        Spacer()
                        TextField("X Market", text: $markaText)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Barkod")
                        Spacer()
                        TextField("86000", text: $barkodText)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kategori")
                        Spacer()
                        TextField("Süt ürünleri", text: $kategoriText)
                            .multilineTextAlignment(.trailing)
                    }
                }            }
            .navigationTitle("Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                doldur()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        Task {
                            await kaydet()
                        }
                    }
                    .disabled(kaydediliyor || isim.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func doldur() {
        isim = besin.isim
        kaloriText = "\(besin.kalori)"
        porsiyonBirim = besin.porsiyonBirim ?? "adet"
        miktarText = besin.porsiyonMiktar != nil ? "\(besin.porsiyonMiktar!)" : ""
        proteinText = besin.protein != nil ? "\(besin.protein!)" : ""
        karbonhidratText = besin.karbonhidrat != nil ? "\(besin.karbonhidrat!)" : ""
        sekerText = besin.seker != nil ? "\(besin.seker!)" : ""
        yagText = besin.yag != nil ? "\(besin.yag!)" : ""
        tuzText = besin.tuz != nil ? "\(besin.tuz!)" : ""
        markaText = besin.marka ?? ""
        barkodText = besin.barkod ?? ""
        kategoriText = besin.kategori ?? ""
    }
    private func kaydet() async {
        kaydediliyor = true
        let kalori = Int(kaloriText) ?? 0

        var kucukFoto: Data?
        if let fotoData, let uiImage = UIImage(data: fotoData) {
            kucukFoto = ResimYardimci.kucult(uiImage)
        }

        do {
            let sonuc = try await BesinServisiGuncelle.besinGuncelle(
                id: besin.id,
                isim: isim.trimmingCharacters(in: .whitespaces),
                kalori: kalori,
                porsiyonBirim: porsiyonBirim,
                porsiyonMiktar: makroSayi(miktarText),
                protein: makroSayi(proteinText),
                karbonhidrat: makroSayi(karbonhidratText),
                seker: makroSayi(sekerText),
                yag: makroSayi(yagText),
                tuz: makroSayi(tuzText),
                marka: markaText.trimmingCharacters(in: .whitespaces),
                barkod: barkodText.trimmingCharacters(in: .whitespaces),
                kategori: kategoriText.trimmingCharacters(in: .whitespaces),
                fotoData: kucukFoto
            )
            if sonuc {
                dismiss()
            }
        } catch {
            print("Güncelleme hatası:", error)
        }
        kaydediliyor = false
    }

    private func makroSayi(_ metin: String) -> Double? {
        let temiz = metin.replacingOccurrences(of: ",", with: ".")
        if temiz.trimmingCharacters(in: .whitespaces).isEmpty {
            return nil
        }
        let sonuc = Double(temiz)
        return sonuc
    }
}

#Preview {
    BesinGuncelleView(besin: Besin(
        id: "1",
        isim: "Ayran",
        kalori: 80,
        porsiyonBirim: "adet",
        porsiyonMiktar: 1,
        resim: "ayran.jpg",
        protein: 3.5,
        karbonhidrat: 4.0,
        seker: 4.0,
        yag: 1.5,
        marka: "Pınar",
        barkod: "8690000000000",
        kategori: "Süt Ürünü",
        tuz: 0.3
    ))
}
