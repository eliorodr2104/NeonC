//
//  CreationProjectViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation
internal import Combine

@MainActor
final class CreationProjectViewModel: ObservableObject {
    @Published var languageVersions: [String] = []
    @Published var cmakeVersion: String = ""
    
    @Published var nameProject: String = ""
    @Published var locationProject: String = defaultProjectsRoot().path
    @Published var versionLanguageSelect: String = ""

    // Output utile per la UI
    var baseDirectoryURL: URL {
        let expanded = (locationProject as NSString).expandingTildeInPath
        return URL(fileURLWithPath: expanded, isDirectory: true)
    }
    var projectDirectoryURL: URL {
        baseDirectoryURL.appendingPathComponent(nameProject, isDirectory: true)
    }
    var projectDirectoryPath: String {
        projectDirectoryURL.path
    }

    private let standards: StandardsProvider

    init(standards: StandardsProvider? = nil) {
        self.standards = standards ?? ClangStandardsProvider.shared
        try? ensureBaseDirExists()
    }

    func load(forceRefresh: Bool = false) async {
        let list = await standards.loadDisplayStandards()
        languageVersions = list
        if versionLanguageSelect.isEmpty { versionLanguageSelect = list.first ?? "C90" }
        
        cmakeVersion = await standards.loadCmakeVersion()
    }

    func ensureBaseDirExists() throws {
        try FileManager.default.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)
    }

    func createProject(kind: ProjectKind) async throws -> URL {

        let url = try await ProjectCreator.shared.createProject(
            at: baseDirectoryURL,
            name: nameProject,
            cmakeVersion: cmakeVersion,
            kind: kind,
            standard: String(versionLanguageSelect.dropFirst())
        )
        
        return url
    }

    static func defaultProjectsRoot() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("NeonCProjects", isDirectory: true)
    }
}
