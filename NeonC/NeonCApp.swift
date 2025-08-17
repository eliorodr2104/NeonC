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
    @StateObject private var compilerProfile = CompilerProfileStore()
    @StateObject private var recentProjectsStore = RecentProjectsStore()
    
    init() {
            Task.detached(priority: .utility) {
                _ = SelectTypeProjectView.self
                _ = CreationProjectView.self
                _ = CreationProjectViewModel.self
                _ = EditorView.self
                _ = ProjectTemplatesStore.self
                _ = ModeButton.self
                _ = ModalityBoxView.self
            }
        }

    var body: some Scene {
        
        WindowGroup(id: "home") {
            ContentView(
                navigationState: navigationState,
                lastStateApp: lastStateApp,
                compilerProfile: compilerProfile,
                recentProjectsStore: recentProjectsStore
            )
            .environmentObject(appState)
            
        }
        .windowStyle(.hiddenTitleBar)
        

        // EDITOR
        WindowGroup(id: "editor") {
            EditorView(lastStateApp: lastStateApp, navigationState: navigationState)
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        
    }
}
