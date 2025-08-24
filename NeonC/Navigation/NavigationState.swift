//
//  NavigationState.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

internal import Combine
import AppKit
import SwiftUI

@MainActor
final class NavigationState: ObservableObject {
    private let lastStateApp: LastAppStateStore

    @Published var navigationItem: NavigationItem

    init() {
        self.lastStateApp = LastAppStateStore()

        self.navigationItem = NavigationItem(
            principalNavigation: .HOME,
            currentLanguageProject: .C_EXE,
            selectedProjectName: URL(string: lastStateApp.currentState.lastPathOpened ?? "")?.lastPathComponent ?? "",
            selectedProjectPath: lastStateApp.currentState.lastPathOpened ?? ""
        )
    }
    
    func openProjectPanel() {
        let panel = NSOpenPanel()
        
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open"
        panel.title = "Select Project Directory"

        panel.begin { [weak self] response in
            guard let self = self else { return }
            if response == .OK, let url = panel.url {

                DispatchQueue.main.async {

                    if self.navigationItem.selectedProjectPath != url.path || self.navigationItem.selectedProjectName != url.lastPathComponent {
                        self.navigationItem.selectedProjectPath = url.path
                        self.navigationItem.selectedProjectName = url.lastPathComponent
                        
                        self.navigationItem.secondaryNavigation = .CONTROL_OPEN_PROJECT
                    }
                }
            }
        }
    }

    func showCreationProjectSheet() {
        self.navigationItem.secondaryNavigation = .SELECT_TYPE_PROJECT
    }

    func closeCreateProjectPanel() {
        self.navigationItem.secondaryNavigation = nil
    }
    
    func saveLastProjectState(path: String?) {
        lastStateApp.changeState(path: path)
    }
}


final class AppState: ObservableObject {
    @Published private(set) var editorProjectPath: String? = nil
    let objectWillChange = ObservableObjectPublisher()

    func setEditorProjectPath(_ path: String?) {
        guard editorProjectPath != path else { return }
        
        objectWillChange.send()
        editorProjectPath = path
    }
}
