//
//  ContentView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 10/08/25.
//

import SwiftUI
internal import Combine

struct ContentView: View {
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var lastStateApp: LastAppStateStore
    
    @StateObject private var recentProjectsStore = RecentProjectsStore()
    
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        HomeView(
            navigationState: navigationState,
            recentProjectsStore: recentProjectsStore,
            lastStateApp: lastStateApp
        )
        .sheet(isPresented: $navigationState.showCreateProject) {
            CreationProjectView(navigationState: navigationState)
                .frame(width: 600, height: 400)
        }
        .alert(
            "Open Project '\(navigationState.selectedProjectName)'",
            isPresented: $navigationState.showOpenProjectAlert,
            actions: {
                Button("No", role: .cancel) {
                    // Solo azione leggera
                    navigationState.selectedProjectPath = ""
                }
                .buttonStyle(.glass)
                
                Button("Yes") {
                    let path = navigationState.selectedProjectPath
                    let name = navigationState.selectedProjectName

                    withTransaction(Transaction(animation: nil)) {
                        appState.setEditorProjectPath(path)
                        recentProjectsStore.addProject(name: name, path: path)
                        lastStateApp.changeState(path: path)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        openWindow(id: "editor")

                        DispatchQueue.main.async {
                            navigationState.selectedProjectPath = ""
                            navigationState.selectedProjectName = ""
                            dismiss()
                        }
                    }
                }
                .buttonStyle(.glass)

            }
        )
    }
}

#Preview {
    ContentView(navigationState: NavigationState(), lastStateApp: LastAppStateStore())
}
