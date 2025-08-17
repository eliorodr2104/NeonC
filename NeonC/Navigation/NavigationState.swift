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
    @Published var navigationItem: NavigationItem = NavigationItem()
    
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

    func clearSelection() {
        self.navigationItem.selectedProjectPath = ""
        self.navigationItem.selectedProjectName = ""
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
