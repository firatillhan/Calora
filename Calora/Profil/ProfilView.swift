//
//  ProfilView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI

struct ProfilView: View {
    @AppStorage("boy") private var boy: Double = 0
    @AppStorage("kilo") private var kilo: Double = 0
    @AppStorage("yas") private var yas: Int = 0
    @AppStorage("cinsiyet") private var cinsiyet: String = "erkek"
    @AppStorage("aktivite") private var aktivite: String = "hareketsiz"
    @AppStorage("hedefTur") private var hedefTur: String = "koru"

    private var doldurulmus: Bool {
        boy > 0 && kilo > 0 && yas > 0
    }

    var body: some View {
        NavigationStack {
            Group {
                if doldurulmus {
                    ozet
                } else {
                    ContentUnavailableView(
                        "Profil Boş",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Bilgilerini girmek için Düzenle'ye dokun.")
                    )
                }
            }
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ProfilDuzenleView()
                    } label: {
                        Text("Düzenle")
                    }
                }
            }
        }
    }

    private var ozet: some View {
        List {
            Section("Bilgiler") {
                satir("Boy", "\(Int(boy)) cm")
                satir("Kilo", "\(Int(kilo)) kg")
                satir("Yaş", "\(yas)")
                satir("Cinsiyet", cinsiyet == "erkek" ? "Erkek" : "Kadın")
            }
            Section("İdeal Kilo") {
                satir("Aralık", "\(sonuc.idealAlt)–\(sonuc.idealUst) kg")
            }
            Section("Günlük Hedef") {
                satir("Kalori", "\(sonuc.kalori) kcal")
                satir("Protein", "\(sonuc.protein) g")
                satir("Karbonhidrat", "\(sonuc.karbonhidrat) g")
                satir("Yağ", "\(sonuc.yag) g")
            }
        }
    }

    private func satir(_ ad: String, _ deger: String) -> some View {
        HStack {
            Text(ad)
            Spacer()
            Text(deger)
                .foregroundStyle(.secondary)
        }
    }
    private var aktiviteKatsayi: Double {
        switch aktivite {
        case "az": return 1.375
        case "orta": return 1.55
        case "aktif": return 1.725
        case "cok": return 1.9
        default: return 1.2
        }
    }

    private var sonuc: ProfilSonuc {
        let hesap = ProfilHesap.hesapla(
            boy: boy, kilo: kilo, yas: yas,
            cinsiyet: cinsiyet, aktiviteKatsayi: aktiviteKatsayi, hedef: hedefTur
        )
        return hesap
    }
}

#Preview {
    ProfilView()
}
