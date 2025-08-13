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
    
    private var isCreateProjectPresented: Binding<Bool> {
        Binding(
            get: {
                navigationState.navigationItem.navigationState == .SELECT_TYPE_PROJECT || navigationState.navigationItem.navigationState == .CREATE_PROJECT
            },
            set: { newValue in
                if !newValue {
                    navigationState.closeCreateProjectPanel()
                }
            }
        )
    }
    
    private var isOpenProjectAlertPresented: Binding<Bool> {
        Binding(
            get: {
                navigationState.navigationItem.navigationState == .OPEN_PROJECT
            },
            set: { newValue in
                if !newValue {
                    navigationState.navigationItem.navigationState = .HOME
                }
            }
        )
    }
    
    var body: some View {
        
        HomeView(
            navigationState: navigationState,
            recentProjectsStore: recentProjectsStore,
            lastStateApp: lastStateApp
        )
        .sheet(isPresented: isCreateProjectPresented) {
            
            if navigationState.navigationItem.navigationState == .SELECT_TYPE_PROJECT {
                SelectTypeProjectView(navigationState: navigationState)
                    .frame(width: 600, height: 400)
            }
            
            if navigationState.navigationItem.navigationState == .CREATE_PROJECT {
                CreationProjectView(navigationState: navigationState)
                    .frame(width: 600, height: 400)

            }
        }
        .alert(
            "Open Project '\(navigationState.navigationItem.selectedProjectName)'",
            isPresented: isOpenProjectAlertPresented,
            actions: {
                Button("No", role: .cancel) {
                    navigationState.navigationItem.selectedProjectPath = ""
                }
                .buttonStyle(.glass)
                
                Button("Yes") {
                    let path = navigationState.navigationItem.selectedProjectPath
                    let name = navigationState.navigationItem.selectedProjectName

                    withTransaction(Transaction(animation: nil)) {
                        appState.setEditorProjectPath(path)
                        recentProjectsStore.addProject(name: name, path: path)
                        lastStateApp.changeState(path: path)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        openWindow(id: "editor")

                        DispatchQueue.main.async {
                            navigationState.navigationItem.selectedProjectPath = ""
                            navigationState.navigationItem.selectedProjectName = ""
                            navigationState.navigationItem.navigationState = .HOME
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
