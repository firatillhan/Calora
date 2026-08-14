//
//  CaloraApp.swift
//  Calora
//
//  Created by Fırat İlhan on 4.08.2026.
//

import SwiftUI
import SwiftData

@main
struct CaloraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Kayit.self, GunlukHedef.self])
    }
}
