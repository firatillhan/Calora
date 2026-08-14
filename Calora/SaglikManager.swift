
import Foundation
import HealthKit
import Combine

@MainActor
final class SaglikManager: ObservableObject {

    static let shared = SaglikManager()
    private let store = HKHealthStore()

    @Published var izinVar = false
    @Published var yukleniyor = false
    @Published var bugunYakilan = 0

    private init() {}

    func bugunuCek() {
        guard HKHealthStore.isHealthDataAvailable(),
              let tur = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("HealthKit yok")
            return
        }

        yukleniyor = true

        store.requestAuthorization(toShare: nil, read: [tur]) { basarili, hata in
            Task { @MainActor in
                self.izinVar = basarili
                if !basarili {
                    self.yukleniyor = false
                    print("İzin yok:", hata?.localizedDescription ?? "")
                    return
                }
                self.sorgula(tur)
            }
        }
    }

    private func sorgula(_ tur: HKQuantityType) {
        let takvim = Calendar.current
        let baslangic = takvim.startOfDay(for: Date())
        let kosul = HKQuery.predicateForSamples(withStart: baslangic, end: Date())

        let sorgu = HKStatisticsQuery(
            quantityType: tur,
            quantitySamplePredicate: kosul,
            options: .cumulativeSum
        ) { _, sonuc, _ in
            let deger = sonuc?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            Task { @MainActor in
                self.bugunYakilan = Int(deger.rounded())
                self.yukleniyor = false
                print("Bugün yakılan kalori:", self.bugunYakilan)
            }
        }
        store.execute(sorgu)
    }
    func dunuCekVeKaydet(kaydet: @escaping (Int) -> Void) {
        guard HKHealthStore.isHealthDataAvailable(),
              let tur = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            return
        }
        let takvim = Calendar.current
        guard let dun = takvim.date(byAdding: .day, value: -1, to: Date()) else { return }
        let baslangic = takvim.startOfDay(for: dun)
        let bitis = takvim.startOfDay(for: Date())
        let kosul = HKQuery.predicateForSamples(withStart: baslangic, end: bitis)

        let sorgu = HKStatisticsQuery(quantityType: tur, quantitySamplePredicate: kosul, options: .cumulativeSum) { _, sonuc, _ in
            let deger = sonuc?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            print("DÜN YAKILAN (sorgu):", Int(deger.rounded()))

            Task { @MainActor in
                kaydet(Int(deger.rounded()))
            }
        }
        store.execute(sorgu)
    }
}
