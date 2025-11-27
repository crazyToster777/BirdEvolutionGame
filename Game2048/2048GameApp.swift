//
//  newgameApp.swift
//  newgame
//
//  Created by Dany on 02/08/2025.
//

import SwiftUI

@main
struct newgameApp: App {
    
    @StateObject private var gameViewModel = Game2048ViewModel()
    @StateObject private var audioManager = AudioManager.shared
    
    init() {
        // Start background music when app launches
        AudioManager.shared.playBackgroundMusic()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(gameViewModel)
                .environmentObject(audioManager)
        }
    }
}
