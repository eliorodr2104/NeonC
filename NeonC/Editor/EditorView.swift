//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct EditorView: View {
    let projectPath: String
    
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject         private var appState    : AppState
    @ObservedObject            private var lastStateApp: LastAppStateStore
    

    
    
    @State private var isRunning: Bool
    
    init(lastStateApp: LastAppStateStore) {
        
        self.projectPath  = lastStateApp.currentState.lastPathOpened ?? ""
        self.lastStateApp = lastStateApp
        self.isRunning    = false
    }

    var body: some View {
        
        NavigationSplitView {
            List {
                Label("House", systemImage:"house")
                Label("Documents", systemImage: "doc")
            }
            .navigationTitle("Sidebar")
            
        } detail: {
            VStack {
                Spacer()
                Text(projectPath)
                    .font(.title)
                    .multilineTextAlignment(.center)
                Spacer()
                
            }
            
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
            ToolbarItem {
                GlassEffectContainer(spacing: 40) {
                    HStack(spacing: 7.0) {

                        Button {
                            withAnimation(.spring()) {
                                isRunning = true
                            }
                        } label: {
                            Image(systemName: isRunning ? "play.fill" : "play")
                                .font(.system(size: 20))
                        }
                        .frame(width: 40.0, height: 40.0)
                        .buttonStyle(.glass)

                        if isRunning {
                            Button {
                                withAnimation(.spring()) {
                                    isRunning = false
                                }
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 40.0, height: 40.0)
                            .buttonStyle(.glass)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        } else {
                            // Placeholder trasparente: mantiene fisso il layout
                            Color.clear
                                .frame(width: 40.0, height: 40.0)
                                .allowsHitTesting(false)
                        }
                    }
                    .animation(.spring(), value: isRunning)
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}

#Preview {
    EditorView(lastStateApp: LastAppStateStore())
}
