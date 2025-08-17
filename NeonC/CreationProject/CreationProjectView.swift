//
//  CreationProjectView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

struct CreationProjectView: View {
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var compilerProfile: CompilerProfileStore
    
    @StateObject private var viewModel: CreationProjectViewModel

    @State private var creating: Bool = false
    @State private var createError: String? = nil
    @State private var urlProject: URL? = nil

    init(navigationState: NavigationState, compilerProfile: CompilerProfileStore) {
        self.navigationState = navigationState
        self.compilerProfile = compilerProfile
        _viewModel = StateObject(wrappedValue: CreationProjectViewModel(compilerProfile: compilerProfile))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set your new project")
                .font(.title2).bold()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Project name:")
                TextField("Project name", text: $viewModel.nameProject)
                    .textFieldStyle(.roundedBorder)
                
                Text("Location:")
                TextField("Location", text: $viewModel.locationProject)
                    .textFieldStyle(.roundedBorder)
                
                Text("Language Standard:")
                Picker("Scegli", selection: $viewModel.versionLanguageSelect) {
                    ForEach(viewModel.languageVersions, id: \.self) { v in
                        Text(v).tag(v)
                    }
                }
                .pickerStyle(PopUpButtonPickerStyle())
                .disabled(viewModel.languageVersions.isEmpty)
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button("Back") { navigationState.closeCreateProjectPanel() }
                    .buttonStyle(.glass)
                
                Spacer()
                
                Button("Next") {
                    Task {
                        await createAction()
                        
                        if let path = urlProject?.path, !path.isEmpty, createError == nil {
                            navigationState.clearSelection()
                            navigationState.navigationItem.selectedProjectPath = path
                            navigationState.navigationItem.selectedProjectName = viewModel.nameProject
                            navigationState.navigationItem.secondaryNavigation = .CONTROL_OPEN_PROJECT
                        }
                    }
                }
                .buttonStyle(.glassProminent)
                .disabled(creating || viewModel.nameProject.isEmpty || viewModel.locationProject.isEmpty)
            }
        }
        .padding()
        .task {
            await viewModel.load()
        }
    }
    
    private func createAction() async {
        creating = true
        defer { creating = false }
        do {
            // Get the current language project to create
            let kind = mapProjectKind(from: navigationState)
            // Create and get the project
            urlProject = try await viewModel.createProject(kind: kind)
        } catch {
            createError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    private func mapProjectKind(from navigationState: NavigationState) -> ProjectKind {
        switch navigationState.navigationItem.currentLanguageProject {
            case .C_EXE:     return .cExe
            case .C_LIB:     return .cLib
            case .CPP_EXE:   return .cppExe
            case .CPP_LIB:   return .cppLib
            default:         return .cExe
        }
    }
}

