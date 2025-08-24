//
//  EditorView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct EditorView: View {
    
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject         private var appState       : AppState
    
    @ObservedObject            private var navigationState: NavigationState
    @ObservedObject            private var compilerProfile: CompilerProfileStore
    
    // Searching File
    @State private var searchFile         : Bool
    
    // Runnig section
    @State private var editorStatus       : EditorStatus
    
    // Tree file section
    @State private var treeRefreshTrigger : Bool
    @State private var selectedFile       : URL?
    
    
    init(navigationState: NavigationState, compilerProfile: CompilerProfileStore) {
        self.editorStatus       = .readyToBuild
        
        self.navigationState    = navigationState
        self.compilerProfile    = compilerProfile
        self.searchFile         = false
        self.treeRefreshTrigger = false
        
        self._selectedFile = State(initialValue: nil)
        
    }

    var body: some View {
        NavigationSplitView {
            
            DirectoryTreeView(
                rootURL: URL(fileURLWithPath: navigationState.navigationItem.selectedProjectPath),
                refreshTrigger: treeRefreshTrigger
                
            ) { url in
                selectedFile = url
            }
            .onChange(of: editorStatus == .build) { _, newValue in
                if newValue {
                    treeRefreshTrigger.toggle()
                }
            }
                                    
        } detail: {
            
            ZStack {
                let projectPath = URL(fileURLWithPath: navigationState.navigationItem.selectedProjectPath)
                let isEmptyPath = selectedFile == nil
                                
                if  !isEmptyPath {
                    ContextView(
                        compilerProfile: compilerProfile,
                        projectRoot: projectPath,
                        selectedFile: selectedFile!
                    )
                    
                }
                
                if searchFile || isEmptyPath {
                    
                    FileSearchView(directory: projectPath) { currentFile in
                        selectedFile = currentFile.url
                        searchFile = false
                        
                    }
                    .transition(.opacity)
                    .zIndex(1)
                    
                }
                
            }
                
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            withTransaction(Transaction(animation: nil)) {
                appState.setEditorProjectPath(nil)
                navigationState.saveLastProjectState(path: nil)
            }
            
            DispatchQueue.main.async {
                openWindow(id: "home")
            }
            
        }
        .toolbar {
            
            // Section toolbar, this contains running execution button
            ToolbarItem(placement: .navigation) {
                
                GlassEffectContainer(spacing: 35) {
                    
                    HStack(spacing: 7.0) {
                        Button {
                            withAnimation(.spring()) {
                                if editorStatus == .readyToBuild || editorStatus == .stopped{
                                    
                                    editorStatus = .building
                                    
                                }
                                
                            }
                            
                        } label: {
                            Image(systemName: "play")
                                .font(.system(size: 17))
                            
                        }
                        .frame(width: 35.0, height: 35.0)
                        .buttonStyle(.glass)
                        
                        if editorStatus != .readyToBuild && editorStatus != .stopped {
                            
                            Button {
                                withAnimation(.spring()) {
                                    
                                    if editorStatus != .readyToBuild || editorStatus != .stopped {
                                        
                                        editorStatus = .stopped
                                        
                                    }
                                    
                                }
                                
                            } label: {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 17))
                                
                            }
                            .frame(width: 35.0, height: 35.0)
                            .buttonStyle(.glass)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        } else {
                            Color.clear
                                .frame(width: 35.0, height: 35.0)
                                .allowsHitTesting(false)
                            
                        }
                    }
                    .animation(.spring(), value: editorStatus)
                }
            }
            .sharedBackgroundVisibility(.hidden)

            // Center Section for view current file working and search file
            ToolbarItemGroup(placement: .principal) {
                HStack {
                    HStack {
                        Text(navigationState.navigationItem.selectedProjectName)
                        
                        Spacer(minLength: 80)
                        
                        let projectName = navigationState.navigationItem.selectedProjectName
                        switch editorStatus {
                        case .readyToBuild:
                            Text("\(projectName) is ready to build")
                        case .building:
                            Text("\(projectName) is building")
                        case .build:
                            Text("\(projectName) is build")
                        case .running:
                            Text("\(projectName) is running")
                        case .stopped:
                            Text("Finished running \(projectName)")
                        }
                    }
                    .padding(10)
                    .glassEffect()
                    
                    // Search button
                    Button {
                        withAnimation(.spring()) {
                            if selectedFile != nil { searchFile.toggle() }
                        }
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15))
                    }
                    .frame(width: 35.0, height: 35.0)
                    .buttonStyle(.glass)
                }
            }
            .sharedBackgroundVisibility(.hidden)
            
            
        }
        .onAppear {
            let buildPath = URL(fileURLWithPath: self.navigationState.navigationItem.selectedProjectPath).appendingPathComponent("build")
            let isBuildFolderExists = FileManager.default.fileExists(atPath: buildPath.path, isDirectory: nil)

            if !isBuildFolderExists {
                editorStatus = .building
                
                ensureCompileCommands(
                    at: URL(fileURLWithPath: self.navigationState.navigationItem.selectedProjectPath),
                    cmakeExecutablePath: compilerProfile.currentProfile.cmakePath,
                    ninjaExecutablePath: compilerProfile.currentProfile.ninjaPath,
                    clangExecutablePath: compilerProfile.currentProfile.compilerCPath,
                    completion: { success in
                        
                        editorStatus = success ? .readyToBuild : .stopped
                        
                    }
                    
                )
            }
            
        }

    }

}

#Preview {
    EditorView(navigationState: NavigationState(), compilerProfile: CompilerProfileStore())
}

