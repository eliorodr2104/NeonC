//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct EditorView: View {
    
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject         private var appState    : AppState
    
    @ObservedObject            private var lastStateApp: LastAppStateStore
    @ObservedObject            private var navigationState: NavigationState

    @State private var isRunning: Bool
    @State private var selectedFile: URL?

    init(lastStateApp: LastAppStateStore, navigationState: NavigationState) {
        
        self.lastStateApp = lastStateApp
        self.isRunning    = false
        self.navigationState = navigationState
        
    }

    var body: some View {
        
        NavigationSplitView {
            DirectoryTreeView(rootURL: URL(fileURLWithPath: self.lastStateApp.currentState.lastPathOpened!)) { url in
                selectedFile = url
            }
            
        } detail: {
            
            ContextView(selectedFile: selectedFile)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {

            withTransaction(Transaction(animation: nil)) {
                appState.setEditorProjectPath(nil)
                lastStateApp.changeState(path: nil)
            }

            DispatchQueue.main.async {
                openWindow(id: "home")
            }
        }
        .toolbar {
            
            ToolbarItem(placement: .navigation) {
                GlassEffectContainer(spacing: 35) {
                    HStack(spacing: 7.0) {

                        Button {
                            withAnimation(.spring()) {
                                isRunning = true
                            }
                        } label: {
                            Image(systemName: isRunning ? "play.fill" : "play")
                                .font(.system(size: 17))
                        }
                        .frame(width: 35.0, height: 35.0)
                        .glassEffect() 

                        if isRunning {
                            Button {
                                withAnimation(.spring()) {
                                    isRunning = false
                                }
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 17))
                            }
                            .frame(width: 35.0, height: 35.0)
                            .glassEffect()
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        } else {
                            Color.clear
                                .frame(width: 35.0, height: 35.0)
                                .allowsHitTesting(false)
                            
                        }
                    }
                    .animation(.spring(), value: isRunning)
                }
            }
            .sharedBackgroundVisibility(.hidden)

            ToolbarItem(placement: .principal) {
                HStack {
                    Text(navigationState.navigationItem.selectedProjectName)
                }
                .padding()
            }
        }
        .onAppear {
            self.navigationState.navigationItem.selectedProjectPath = self.lastStateApp.currentState.lastPathOpened!
            self.navigationState.navigationItem.selectedProjectName = URL(fileURLWithPath: self.navigationState.navigationItem.selectedProjectPath).lastPathComponent
        }
    }
}

#Preview {
    EditorView(lastStateApp: LastAppStateStore(), navigationState: NavigationState())
}

