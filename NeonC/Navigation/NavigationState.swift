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
    @Published var showOpenProjectAlert: Bool   = false
    @Published var showCreateProject   : Bool   = false
    @Published var selectedProjectName : String = ""
    @Published var selectedProjectPath : String = ""

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

                    if self.selectedProjectPath != url.path || self.selectedProjectName != url.lastPathComponent {
                        self.selectedProjectPath = url.path
                        self.selectedProjectName = url.lastPathComponent
                        self.showOpenProjectAlert = true
                    }
                }
            }
        }
    }

    func showCreateProjectPanel() {
        showCreateProject = true
    }

    func closeCreateProjectPanel() {
        showCreateProject = false
    }

    func clearSelection() {
        selectedProjectPath = ""
        selectedProjectName = ""
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
