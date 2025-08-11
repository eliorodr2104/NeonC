//
//  NeonCApp.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 10/08/25.
//

import SwiftUI
internal import Combine

@main
struct NeonCApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var navigationState = NavigationState()
    @StateObject private var lastStateApp = LastAppStateStore()

    var body: some Scene {
        
        // HOME (usiamo ContentView come root della "home")
        WindowGroup(id: "home") {
            ContentView(navigationState: navigationState, lastStateApp: lastStateApp)
                .environmentObject(appState)
                
        }
        .windowStyle(.hiddenTitleBar)

        // EDITOR
        WindowGroup(id: "editor") {
            EditorView(lastStateApp: lastStateApp)
                .environmentObject(appState)
                
        }
        .windowStyle(.hiddenTitleBar)
    }
}
