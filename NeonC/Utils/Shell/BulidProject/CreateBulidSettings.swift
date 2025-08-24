//
//  CreateBulidSettings.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/08/25.
//

import Foundation

/// Create a build settings for clangd LSP
func ensureCompileCommands(
    at projectRoot: URL,
    cmakeExecutablePath: String,
    ninjaExecutablePath: String,
    clangExecutablePath: String,
    completion: @escaping (Bool) -> Void

) {

    let buildDir = projectRoot.appendingPathComponent("build")
    let buildDB = buildDir.appendingPathComponent("compile_commands.json")
    let cmakeCache = buildDir.appendingPathComponent("CMakeCache.txt")

    // If already present, done
    if fileExists(buildDB.path) {
        completion(true); return
    }

    guard fileExists(cmakeExecutablePath), binaryIsExecutable(at: cmakeExecutablePath) else {
        DispatchQueue.main.async {
            print("cmake not found executable at: \(cmakeExecutablePath)")
            completion(false)
        }
        return
    }

    var preferredGenerators: [String] = []
    if binaryIsExecutable(at: ninjaExecutablePath) {
        preferredGenerators.append("Ninja")
    }
    preferredGenerators.append("Unix Makefiles") // fallback

    DispatchQueue.global(qos: .utility).async {
        var succeeded = false
        var triedGenerators: [String] = []

        let clangExists = FileManager.default.isExecutableFile(atPath: clangExecutablePath)
        let compilerArg = clangExists ? ["-DCMAKE_C_COMPILER=\(clangExecutablePath)"] : []

        for gen in preferredGenerators {
            triedGenerators.append(gen)

            if fileExists(cmakeCache.path) {
                removeBuildDir(buildDir)
            }

            var configureArgs = ["-S", projectRoot.path,
                                 "-B", buildDir.path,
                                 "-G", gen,
                                 "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"]

            // Set ninja path
            if gen == "Ninja" {
                configureArgs.append("-DCMAKE_MAKE_PROGRAM=\(ninjaExecutablePath)")
            }
            if !compilerArg.isEmpty { configureArgs.append(contentsOf: compilerArg) }

            let conf = runCommand(cmakeExecutablePath, configureArgs)

            if conf.exitCode != 0 {
                continue
            }

            if fileExists(buildDB.path) {
                succeeded = true
                break
                
            } else {
                let buildRes = runCommand(cmakeExecutablePath, ["--build", buildDir.path])
                
                if buildRes.exitCode == 0 && fileExists(buildDB.path) {
                    succeeded = true
                    break
                }
            }
        }

        DispatchQueue.main.async {
            if !succeeded {
                print("ensureCompileCommands: failed. Tried generators: \(triedGenerators). Check cmake/ninja/clang installation and project CMakeLists.")
            }
            completion(succeeded)
        }
    }
}

private func binaryIsExecutable(at path: String) -> Bool {
    guard !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
    return FileManager.default.isExecutableFile(atPath: path)
}

private func fileExists(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
}

private func removeBuildDir(_ buildDir: URL) {
    
    do {
        
        if FileManager.default.fileExists(atPath: buildDir.path) {
            try FileManager.default.removeItem(at: buildDir)
        }
        
    } catch {
        print("Failed to remove build dir: \(error)")
        
    }
}
