//
//  newgameApp.swift
//  newgame
//
//  Created by Dany on 02/08/2025.
//

import SwiftUI
import GoogleMobileAds

@main
struct newgameApp: App {
    init() {
       MobileAds.shared.start() { initializationStatus in
               print("AdMob SDK initialized")
           }
       }
    
    @StateObject private var gameViewModel = Game2048ViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(gameViewModel)
        }
    }
}
