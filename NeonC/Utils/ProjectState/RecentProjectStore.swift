//
//  RecentProjectStore.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import Foundation
internal import Combine
import SwiftUI

class RecentProjectsStore: ObservableObject {
    @Published private(set) var projects: [RecentProject] = []

    private let maxProjects = 20
    private let fileURL: URL

    init() {
        
        // Path: ~/Library/Application Support/NeonC/StateIDE
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = directory
            .appendingPathComponent("NeonC", isDirectory: true)
            .appendingPathComponent("Settings", isDirectory: true)
            .appendingPathComponent("StateIDE", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            
        } catch {
            print("Erorr to create StateIDE folder: ", error)
            
        }

        self.fileURL = folder.appendingPathComponent("recent-projects.json")
        load()
    }

    func addProject(name: String, path: String, language: TypeProject) {
        let project = RecentProject(name: name, path: path, language: language)

        // Remove duplicate
        if let existingIndex = projects.firstIndex(where: { $0.path == path }) {
            projects.remove(at: existingIndex)
        }

        projects.insert(project, at: 0)

        // Limit array to max quantity
        if projects.count > maxProjects {
            projects = Array(projects.prefix(maxProjects))
        }

        save()
    }

    func removeProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        
        do {
            let loaded = try JSONDecoder().decode([RecentProject].self, from: data)
            self.projects = loaded
            
        } catch {
            print("Error load recent-projects file: ", error)
            
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(projects)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error save recent-projects file: ", error)
        }
    }
}
