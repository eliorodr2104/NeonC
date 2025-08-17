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
    @ObservedObject var compilerProfile: CompilerProfileStore
    
    @ObservedObject var recentProjectsStore: RecentProjectsStore
        
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    private var isCreateProjectPresented: Binding<Bool> {
        Binding(
            get: {
                navigationState.navigationItem.secondaryNavigation == .SELECT_TYPE_PROJECT || navigationState.navigationItem.secondaryNavigation == .CREATE_PROJECT
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
                navigationState.navigationItem.secondaryNavigation == .CONTROL_OPEN_PROJECT
            },
            set: { newValue in
                if !newValue {
                    navigationState.navigationItem.secondaryNavigation = nil
                }
            }
        )
    }
    
    var body: some View {
        Group {
            switch navigationState.navigationItem.principalNavigation {
            case .HOME:
                HomeView(
                    navigationState: navigationState,
                    recentProjectsStore: recentProjectsStore,
                    lastStateApp: lastStateApp
                )
                .onAppear {
                    if compilerProfile.isEmpty() {
                        navigationState.navigationItem.principalNavigation = .WELCOME_APP
                    }
                }
                .sheet(isPresented: isCreateProjectPresented) {
                    switch navigationState.navigationItem.secondaryNavigation {
                        
                        case .SELECT_TYPE_PROJECT:
                            SelectTypeProjectView(navigationState: navigationState)
                                .frame(width: 600, height: 400)
                            
                        case .CREATE_PROJECT:
                            CreationProjectView(navigationState: navigationState, compilerProfile: compilerProfile)
                                .frame(width: 600, height: 400)
                        
                        default:
                            EmptyView()
                    }
                }

                .alert(
                    "Open Project '\(navigationState.navigationItem.selectedProjectName)'",
                    isPresented: isOpenProjectAlertPresented,
                    actions: {
                        Button("No", role: .cancel) {
                            navigationState.navigationItem.selectedProjectPath = ""
                            navigationState.navigationItem.secondaryNavigation = nil
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
                                    
                                    dismiss()
                                }
                            }
                        }
                        .buttonStyle(.glass)

                    }
                    
                )
            case .WELCOME_APP:
                WelcomeView(navigationState: navigationState)
                
            case .SET_PATHS_APP:
                SelectPathView(compilerProfile: compilerProfile, navigationState: navigationState)
                
            }
        }
        
    }
        
}

#Preview {
    ContentView(navigationState: NavigationState(), lastStateApp: LastAppStateStore(), compilerProfile: CompilerProfileStore(), recentProjectsStore: RecentProjectsStore())
}

