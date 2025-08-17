//
//  CompilerProfileStore.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import Foundation
internal import Combine

class CompilerProfileStore: ObservableObject {
    @Published private(set) var currentProfile: CompileProfile = CompileProfile()

    private let fileURL: URL

    init() {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = directory
            .appendingPathComponent("NeonC", isDirectory: true)
            .appendingPathComponent("Settings", isDirectory: true)
            .appendingPathComponent("Compile_profile", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            print("Creation StateIDE error: ", error)
        }

        self.fileURL = folder.appendingPathComponent("compile-profile.json")
        load()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            let loaded = try JSONDecoder().decode(CompileProfile.self, from: data)
            self.currentProfile = loaded
        } catch {
            print("Error load state: ", error)
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(currentProfile)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Error save state: ", error)
        }
    }
    
    func isEmpty() -> Bool {
        return currentProfile.compilerCPath == "" && currentProfile.compilerCppPath == "" && currentProfile.cmakePath == "" && currentProfile.ninjaPath == "" && currentProfile.makePath == ""
    }

    func updateProfile(profile: CompileProfile) {
        self.currentProfile = profile
        save()
    }
}
