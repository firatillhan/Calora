//
//  BesinEkleView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import PhotosUI

struct BesinEkleView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isim = ""
    @State private var kaloriText = ""
    @State private var porsiyonBirim = "adet"
    @State private var miktarText = ""
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

    @State private var kameraAcik = false
    @State private var secimAcik = false
    @State private var galeriAcik = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        secimAcik = true
                    } label: {
                        if let fotoData, let uiImage = UIImage(data: fotoData) {
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(height: 180).frame(maxWidth: .infinity).clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Label("Fotoğraf Ekle", systemImage: "camera")
                        }
                    }
                    .confirmationDialog("Fotoğraf", isPresented: $secimAcik) {
                        Button("Galeriden Seç") { galeriAcik = true }
                        Button("Fotoğraf Çek") { kameraAcik = true }
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
                        Text("Marka")
                        Spacer()
                        TextField("", text: $markaText)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kategori")
                        Spacer()
                        TextField("", text: $kategoriText)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Barkod")
                        Spacer()
                        TextField("", text: $barkodText)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section("Kalori ve Porsiyon") {
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
                        Text("Protein (g)")
                        Spacer()
                        TextField("", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Karbonhidrat (g)")
                        Spacer()
                        TextField("", text: $karbonhidratText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Şeker (g)")
                        Spacer()
                        TextField("", text: $sekerText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Yağ (g)")
                        Spacer()
                        TextField("", text: $yagText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Tuz (g)")
                        Spacer()
                        TextField("", text: $tuzText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Yeni Besin")
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
            .photosPicker(isPresented: $galeriAcik, selection: $secilenFoto, matching: .images)
            .onChange(of: secilenFoto) { _, yeni in
                Task {
                    fotoData = try? await yeni?.loadTransferable(type: Data.self)
                }
            }
            .fullScreenCover(isPresented: $kameraAcik) {
                KameraView { veri in
                    fotoData = veri
                }
                .ignoresSafeArea()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func kaydet() async {
        kaydediliyor = true

        let kalori = Int(kaloriText) ?? 0

        var kucukFoto: Data?
        if let fotoData, let uiImage = UIImage(data: fotoData) {
            kucukFoto = ResimYardimci.kucult(uiImage)
        }

        do {
            let sonuc = try await BesinServisiEkle.besinEkle(
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
            print("Ekleme hatası:", error)
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
    BesinEkleView()
}
