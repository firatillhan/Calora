//
//  SwiftUIView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import SDWebImageSwiftUI

struct BesinListView: View {
    @State private var besinler: [Besin] = []
    @State private var yukleniyor = false
    @State private var hataMesaji: String?
    
    var body: some View {
            List(besinler) { besin in
                NavigationLink {
                    BesinDetayView(besin: besin)
                } label: {
                    HStack {
                        WebImage(url: resimURL(besin)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundStyle(.secondary)
                                )
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(besin.isim)
                        Spacer()
                        Text("\(besin.kalori) kcal")
                            .foregroundStyle(.secondary)
                    }

                }
            }
            .navigationTitle("Besinler")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        BesinEkleView()
                    }
                    label: {
//                        Image(systemName: "plus")
                        Text("Yeni Besin Ekle")
                    }
                }
            } //toolbar bitiş
            .overlay {
                if yukleniyor {
                    ProgressView()
                } else if let hataMesaji {
                    ContentUnavailableView("Hata",systemImage: "wifi.slach",description: Text(hataMesaji))
                }
            }
            .task {
                await yukle()
            }
           
        
    }
    
    
    private func yukle() async {
        yukleniyor = true
        hataMesaji = nil
        do {
            let gelen = try await BesinServisiGetir.besinGetir()
            besinler = gelen
        } catch {
            if (error as NSError).code == NSURLErrorCancelled {
                   return
               }
            hataMesaji = "Katalog yüklenemedi"
            print("YUKLEME HATASI:", error)
        }
        yukleniyor = false
    }
    private func resimURL(_ besin: Besin) -> URL? {
        guard let resim = besin.resim else {
            return nil
        }
        let tam = BesinServisiGetir.resimTemelURL + resim
        return URL(string: tam)
    }
    
    
}

#Preview {
    BesinListView()
}
