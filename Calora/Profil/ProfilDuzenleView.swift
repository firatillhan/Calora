//
//  ProfilView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI

struct ProfilDuzenleView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("boy") private var boy: Double = 0
    @AppStorage("kilo") private var kilo: Double = 0
    @AppStorage("yas") private var yas: Int = 0
    @AppStorage("cinsiyet") private var cinsiyet: String = "erkek"
    @AppStorage("aktivite") private var aktivite: String = "hareketsiz"
    @AppStorage("hedefTur") private var hedefTur: String = "koru"

    @State private var boyText = ""
    @State private var kiloText = ""
    @State private var yasText = ""
    @State private var cinsiyetSecim = "erkek"
    @State private var aktiviteSecim = "hareketsiz"
    @State private var hedefSecim = "koru"

    var body: some View {
        NavigationStack {
            Form {
                Section("Bilgiler") {
                    HStack {
                        Text("Boy (cm)")
                        Spacer()
                        TextField("170", text: $boyText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Kilo (kg)")
                        Spacer()
                        TextField("70", text: $kiloText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Yaş")
                        Spacer()
                        TextField("25", text: $yasText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Cinsiyet", selection: $cinsiyetSecim) {
                        Text("Erkek").tag("erkek")
                        Text("Kadın").tag("kadin")
                    }
                    .pickerStyle(.segmented)
                }

                Section("Aktivite") {
                    ForEach(aktiviteSecenekleri, id: \.anahtar) { secenek in
                        Button {
                            aktiviteSecim = secenek.anahtar
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(secenek.baslik)
                                        .foregroundStyle(.primary)
                                        .fontWeight(.semibold)
                                    Text(secenek.aciklama)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if aktiviteSecim == secenek.anahtar {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                Section("Hedef") {
                    Picker("Hedef", selection: $hedefSecim) {
                        Text("Kilo ver").tag("ver")
                        Text("Koru").tag("koru")
                        Text("Kilo al").tag("al")
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Profil Düzenle")
            .onAppear { doldur() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kaydet") {
                        kaydet()
                        dismiss()
                    }
                }
            }
        }
    }

    private func doldur() {
        boyText = boy > 0 ? "\(boy)" : ""
        kiloText = kilo > 0 ? "\(kilo)" : ""
        yasText = yas > 0 ? "\(yas)" : ""
        cinsiyetSecim = cinsiyet
        aktiviteSecim = aktivite
        hedefSecim = hedefTur
    }
    private let aktiviteSecenekleri: [(anahtar: String, baslik: String, aciklama: String, katsayi: Double)] = [
        ("hareketsiz", "Hareketsiz", "Masa başı iş, egzersiz yok", 1.2),
        ("az", "Az Hareketli", "Haftada 1-3 gün hafif egzersiz", 1.375),
        ("orta", "Orta Hareketli", "Haftada 3-5 gün egzersiz", 1.55),
        ("aktif", "Hareketli", "Haftada 6-7 gün egzersiz", 1.725),
        ("cok", "Çok Hareketli", "Fiziksel iş + yoğun egzersiz", 1.9)
    ]
    private func kaydet() {
        boy = Double(boyText.replacingOccurrences(of: ",", with: ".")) ?? 0
        kilo = Double(kiloText.replacingOccurrences(of: ",", with: ".")) ?? 0
        yas = Int(yasText) ?? 0
        cinsiyet = cinsiyetSecim
        aktivite = aktiviteSecim
        hedefTur = hedefSecim
    }
}

#Preview {
    ProfilDuzenleView()
}
