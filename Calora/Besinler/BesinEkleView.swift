//
//  BesinEkleView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import PhotosUI
import FoundationModels

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
    @State private var kategoriText = ""
    
    @State private var secilenFoto: PhotosPickerItem?
    @State private var fotoData: Data?

    @State private var kaydediliyor = false

    @State private var kameraAcik = false
    @State private var secimAcik = false
    @State private var galeriAcik = false
    
    
    @State private var hesaplaniyor: Bool = false
    @State private var uyariGoster: Bool = false
    
    private var modelKullanilabilir: Bool {
        if #available(iOS 26, *) {
            let durum = SystemLanguageModel.default.availability
            print("Model durumu:", durum)
            switch durum {
            case .available:
                return true
            default:
                return false
            }
        } else {
            return false
        }
    }
    
    
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
                 
                }

                Section("Kalori ve Porsiyon") {

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
                    
                    Button("Kalori Hesapla") {
                   
                            Task {
                                if #available(iOS 26, *) {
                                    await kaloriHesapla()
                                }
                            }
                        
                    }
                    .disabled(!modelKullanilabilir)
                    HStack {
                        Text("Kalori")
                        Spacer()
                        TextField("", text: $kaloriText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
                    }
                }

                Section("Makrolar") {
                    HStack {
                        Text("Protein (g)")
                        Spacer()
                        TextField("", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
                    }
                    HStack {
                        Text("Karbonhidrat (g)")
                        Spacer()
                        TextField("", text: $karbonhidratText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
                    }
                    HStack {
                        Text("Şeker (g)")
                        Spacer()
                        TextField("", text: $sekerText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
                    }
                    HStack {
                        Text("Yağ (g)")
                        Spacer()
                        TextField("", text: $yagText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
                    }
                    HStack {
                        Text("Tuz (g)")
                        Spacer()
                        TextField("", text: $tuzText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        if hesaplaniyor {
                            ProgressView()
                        }
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
    
    @available(iOS 26, *)
    private func kaloriHesapla() async {
        hesaplaniyor = true
        
        let session = LanguageModelSession()
        let girdi = "\(miktarText) \(porsiyonBirim) \(isim)"
        print("AI'ye gönderilen girdi:", girdi)

        let sonuc = try? await session.respond(to:girdi, generating: BesinBilgisiAI.self)
        print("AI sonucu:", sonuc?.content as Any)
        let kalori = sonuc?.content.kalori
        let protein = sonuc?.content.protein
        let yag = sonuc?.content.yag
        let karbonhidrat = sonuc?.content.karbonhidrat
        let seker = sonuc?.content.seker
        let tuz = sonuc?.content.tuz
        
        if let kalori {
            kaloriText = "\(kalori)"
        }
        
        if let protein {
            proteinText = "\(protein)"
        }
        
        if let yag {
            yagText = "\(yag)"
        }
        
        if let karbonhidrat {
            karbonhidratText = "\(karbonhidrat)"
        }
        
        if let seker {
            sekerText = "\(seker)"
        }
        
        if let tuz {
            tuzText = "\(tuz)"
        }
        
        hesaplaniyor = false
    }
    
}

#Preview {
    BesinEkleView()
}
