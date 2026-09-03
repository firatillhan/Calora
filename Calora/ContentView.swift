//
//  ContentView.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

struct ContentView: View {
    @State private var seciliGun = Date()
    @State private var takvimAcik = false
    
    
    @AppStorage("boy") private var boy: Double = 0
    @AppStorage("kilo") private var kilo: Double = 0
    @AppStorage("yas") private var yas: Int = 0
    @AppStorage("cinsiyet") private var cinsiyet: String = "erkek"
    @AppStorage("aktivite") private var aktivite: String = "hareketsiz"
    @AppStorage("hedefTur") private var hedefTur: String = "koru"
    
    @StateObject private var saglik = SaglikManager.shared
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Kayit.tarih, order: .reverse) private var tumKayitlar: [Kayit]
    @Query private var hedefler: [GunlukHedef]

    @AppStorage("sonDunKayit") private var sonDunKayit = ""
    
    @State private var profilUyari = false
    @State private var profileGit = false

    private var bilgilerEksik: Bool {
        boy == 0 || kilo == 0 || yas == 0
    }
    
    
    private var gununKayitlari: [Kayit] {
        tumKayitlar.filter { kayit in
            Calendar.current.isDate(kayit.tarih, inSameDayAs: seciliGun)
        }
    }
    
    private var toplamKalori: Int {
        var toplam = 0
        for kayit in gununKayitlari {
            toplam += kayit.toplamKalori
        }
        return toplam
    }

    private var toplamProtein: Double {
        var toplam = 0.0
        for kayit in gununKayitlari {
            toplam += kayit.toplamProtein
        }
        return toplam
    }

    private var toplamKarbonhidrat: Double {
        var toplam = 0.0
        for kayit in gununKayitlari {
            toplam += kayit.toplamKarbonhidrat
        }
        return toplam
    }

    private var toplamYag: Double {
        var toplam = 0.0
        for kayit in gununKayitlari {
            toplam += kayit.toplamYag
        }
        return toplam
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

    private var hedef: ProfilSonuc {
        let sonuc = ProfilHesap.hesapla(
            boy: boy, kilo: kilo, yas: yas,
            cinsiyet: cinsiyet, aktiviteKatsayi: aktiviteKatsayi, hedef: hedefTur
        )
        return sonuc
    }
    
    private var ayarliHedef: Int {
        let takvim = Calendar.current
        var gunHedefi = hedef.kalori
        for h in hedefler {
            if takvim.isDate(h.gun, inSameDayAs: seciliGun) {
                gunHedefi = h.hedefKalori
            }
        }
        return gunHedefi + seciliGunYakilan
    }
    
    private var baslik: String {
        let takvim = Calendar.current
        if takvim.isDateInToday(seciliGun) {
            return "Bugün"
        }
        if takvim.isDateInYesterday(seciliGun) {
            return "Dün"
        }
        let bicim = seciliGun.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR")))
        return bicim
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        takvimAcik.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        Text(seciliGun.formatted(.dateTime.day().month(.wide).locale(Locale(identifier: "tr_TR"))))
                            .font(.subheadline.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .rotationEffect(.degrees(takvimAcik ? 180 : 0))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                if takvimAcik {
                    TakvimView(seciliGun: $seciliGun, durum: gunDurumu)
                        .padding(.horizontal)
                    }

                if !gununKayitlari.isEmpty || Calendar.current.isDateInToday(seciliGun) {
                    ozetKart
                        .padding(.horizontal)
                    
                }

                List {
                    ForEach(gununKayitlari) { kayit in
                        NavigationLink {
                            KayitDetayView(kayit: kayit)
                        } label: {
                            HStack {
                                WebImage(url: kayitResimURL(kayit)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 8).fill(Color(.systemGray5))
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(kayit.isim)
                                        .font(.subheadline.bold())
                                    Text("\(kayit.miktar, specifier: "%.1f") birim")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("\(kayit.toplamKalori) kcal")
                                    .font(.subheadline.bold())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: sil)
                }
                .listStyle(.plain)
            }
            .navigationTitle(baslik)
            .alert("Profil Bilgileri Eksik", isPresented: $profilUyari) {
                Button("Tamam") {
                    profileGit = true
                }
            } message: {
                Text("Devam etmek için boy, kilo ve yaş bilgilerini girmen gerekiyor.")
            }
            .navigationDestination(isPresented: $profileGit) {
                ProfilView()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        BesinListView()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        ProfilView()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                
            }
            .onAppear {
                if bilgilerEksik {
                    profilUyari = true
                }
                saglik.bugunuCek()
                gunleriSabitle()
                dunuKaydet()
                print("HEDEF SAYISI:", hedefler.count)
                for h in hedefler {
                    print("GUN:", h.gun, "HEDEF:", h.hedefKalori, "YAKILAN:", h.yakilanKalori)
                }

            }
        }
    }
    
    private var ozetKart: some View {
        let kalan = ayarliHedef - toplamKalori
        return VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Alınan")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(toplamKalori) / \(ayarliHedef) kcal")
                        .font(.title3.bold())
                }
                Spacer()
                if saglik.izinVar {
                    VStack {
                        Text("Yakılan")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if saglik.yukleniyor {
                            ProgressView()
                                .tint(.orange)
                        } else {
                            Text("+\(seciliGunYakilan) kcal")
                                .font(.subheadline.bold())
                                .foregroundStyle(.orange)
                        }
                    }
                    Spacer()
                }
                Text(kalan >= 0 ? "\(kalan) kcal kaldı" : "\(-kalan) kcal aştın")
                    .font(.subheadline)
                    .foregroundStyle(kalan >= 0 ? .green : .red)
            }


            ProgressView(value: min(Double(toplamKalori), Double(ayarliHedef)), total: Double(max(ayarliHedef, 1)))
                .tint(kalan >= 0 ? .green : .red)

            VStack(spacing: 8) {
                makroBar("Protein", toplamProtein, Double(hedef.protein), .blue)
                makroBar("Karbonhidrat", toplamKarbonhidrat, Double(hedef.karbonhidrat), .orange)
                makroBar("Yağ", toplamYag, Double(hedef.yag), .purple)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))


    }
    
    

    //aşılırsa kırmızı oluyor renkli çizgiler.
    private func makroBar(_ ad: String, _ mevcut: Double, _ hedef: Double, _ renk: Color) -> some View {
        let asildi = mevcut > hedef
        return VStack(spacing: 2) {
            HStack {
                Text(ad)
                    .font(.caption)
                Spacer()
                Text("\(Int(mevcut)) / \(Int(hedef)) g")
                    .font(.caption)
                    .foregroundStyle(asildi ? .red : .secondary)
            }
            ProgressView(value: min(mevcut, hedef), total: max(hedef, 1))
                .tint(asildi ? .red : renk)
        }
    }
    private func sil(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(gununKayitlari[index])
        }
        try? modelContext.save()
    }
    private func kayitResimURL(_ kayit: Kayit) -> URL? {
        guard let resim = kayit.resim else { return nil }
        let tam = BesinServisiGetir.resimTemelURL + resim
        return URL(string: tam)
    }
    private func gunDurumu(_ gun: Date) -> Color? {
        let takvim = Calendar.current
        print("takvim zone:\(takvim.timeZone)")
        let gununleri = tumKayitlar.filter { data in
            takvim.isDate(data.tarih, inSameDayAs: gun)
        }
        if gununleri.isEmpty {
            return nil
        }
        var toplam = 0
        for kayit in gununleri {
            toplam += kayit.toplamKalori
        }
        
        

        var gunHedefi = hedef.kalori
        for h in hedefler {
            if takvim.isDate(h.gun, inSameDayAs: gun) {
                gunHedefi = h.hedefKalori
            }
        }

        var gunYakilan = 0
        if takvim.isDateInToday(gun) {
            gunYakilan = saglik.bugunYakilan
        } else {
            for h in hedefler {
                if takvim.isDate(h.gun, inSameDayAs: gun) {
                    gunYakilan = h.yakilanKalori
                }
            }
        }
        gunHedefi += gunYakilan
        
        if toplam > gunHedefi {
            return .red
        }
        return .green
    }
    
    private func hedefiKaydet(_ gun: Date) {
        let takvim = Calendar.current
        let gunBasi = takvim.startOfDay(for: gun)
        let varMi = hedefler.contains { data in
            takvim.isDate(data.gun, inSameDayAs: gunBasi)
        }
        if varMi {
            return
        }
        let yeni = GunlukHedef(
            gun: gunBasi,
            hedefKalori: hedef.kalori
        )
        modelContext.insert(yeni)
        try? modelContext.save()
    }
    
    private var seciliGunYakilan: Int {
        let takvim = Calendar.current
        if takvim.isDateInToday(seciliGun) {
            return saglik.bugunYakilan
        }
        for h in hedefler {
            if takvim.isDate(h.gun, inSameDayAs: seciliGun) {
                return h.yakilanKalori
            }
        }
        return 0
    }
  

    private func dunuKaydet() {
        let takvim = Calendar.current
        guard let dun = takvim.date(byAdding: .day, value: -1, to: Date()) else { return }
        let dunBasi = takvim.startOfDay(for: dun)

        saglik.dunuCekVeKaydet { yakilan in
            for h in hedefler {
                if takvim.isDate(h.gun, inSameDayAs: dunBasi) {
                    if h.yakilanKalori == 0 {
                        h.yakilanKalori = yakilan
                        try? modelContext.save()
                    }
                    return
                }
            }
        }
    }
  
    private func gunleriSabitle() {
        let takvim = Calendar.current
        let bugun = takvim.startOfDay(for: Date())
        var islenmis = Set<Date>()

        for kayit in tumKayitlar {
            let gun = takvim.startOfDay(for: kayit.tarih)
            if islenmis.contains(gun) {
                continue
            }
            islenmis.insert(gun)

            let varMi = hedefler.contains { data in
                takvim.isDate(data.gun, inSameDayAs: gun)
            }
            if !varMi {
                let yeni = GunlukHedef(gun: gun, hedefKalori: hedef.kalori)
                modelContext.insert(yeni)
            }
        }

        var bugunHedefi: GunlukHedef? = nil
        for h in hedefler {
            if takvim.isDate(h.gun, inSameDayAs: bugun) {
                bugunHedefi = h
            }
        }

        if let bulunan = bugunHedefi {
            bulunan.hedefKalori = hedef.kalori
        } else {
            let yeni = GunlukHedef(gun: bugun, hedefKalori: hedef.kalori)
            modelContext.insert(yeni)
        }

        try? modelContext.save()
    }
    
}

#Preview {
    ContentView()
}
