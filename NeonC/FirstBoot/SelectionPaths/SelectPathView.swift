//
//  SelectPathView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ToolPathState: Equatable {
    var path: String
    var isLoading: Bool
    let defaultPath: String
    var notFound: Bool { path == "Not found" }
}

struct SelectPathView: View {
    @ObservedObject var compilerProfile: CompilerProfileStore
    @ObservedObject var navigationState: NavigationState

    @State private var cCompiler = ToolPathState(path: "", isLoading: true, defaultPath: "/usr/bin/clang")
    @State private var cCompilerName: String = ""
    @State private var cppCompiler = ToolPathState(path: "", isLoading: true, defaultPath: "/usr/bin/clang++")
    @State private var cppCompilerName: String = ""
    @State private var make = ToolPathState(path: "", isLoading: true, defaultPath: "/usr/bin/make")
    @State private var makeName: String = ""
    @State private var cmake = ToolPathState(path: "", isLoading: true, defaultPath: "/opt/homebrew/bin/cmake")
    @State private var cmakeName: String = ""
    @State private var ninja = ToolPathState(path: "", isLoading: true, defaultPath: "/opt/homebrew/bin/ninja")
    @State private var ninjaName: String = ""

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Ricerca asincrona dei tool
    func startAllLookups() {
        lookupTool(.cCompiler)
        lookupTool(.cppCompiler)
        lookupTool(.make)
        lookupTool(.cmake)
        lookupTool(.ninja)
    }
    
    enum ToolKind {
        case cCompiler, cppCompiler, make, cmake, ninja
        
        var titles: (name: String, candidates: [String]) {
            switch self {
            case .cCompiler: return ("C Compiler (GCC/Clang)", ["clang", "gcc"])
            case .cppCompiler: return ("C++ Compiler (G++/Clang++)", ["clang++", "g++"])
            case .make: return ("Make", ["make"])
            case .cmake: return ("CMake", ["cmake"])
            case .ninja: return ("Ninja", ["ninja"])
            }
        }
    }
    
    func lookupTool(_ kind: ToolKind) {
        Task.detached(priority: .userInitiated) {
            let candidates = await kind.titles.candidates
            let path = await findFirstToolPath(names: candidates)
            let toolName = path.map { URL(fileURLWithPath: $0).lastPathComponent } ?? ""
            DispatchQueue.main.async {
                switch kind {
                case .cCompiler:
                    cCompiler.path = path ?? "Not found"
                    cCompilerName = toolName
                    cCompiler.isLoading = false
                case .cppCompiler:
                    cppCompiler.path = path ?? "Not found"
                    cppCompilerName = toolName
                    cppCompiler.isLoading = false
                case .make:
                    make.path = path ?? "Not found"
                    makeName = toolName
                    make.isLoading = false
                case .cmake:
                    cmake.path = path ?? "Not found"
                    cmakeName = toolName
                    cmake.isLoading = false
                case .ninja:
                    ninja.path = path ?? "Not found"
                    ninjaName = toolName
                    ninja.isLoading = false
                }
            }
        }
    }
    
    func findFirstToolPath(names: [String]) async -> String? {
        for name in names {
            if let path = await whichOrXcrunOrCommonPaths(name) {
                return path
            }
        }
        return nil
    }

    func whichOrXcrunOrCommonPaths(_ tool: String) async -> String? {
        if let whichPath = try? await shell("which", [tool]), !whichPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let result = whichPath.trimmingCharacters(in: .whitespacesAndNewlines)
            if FileManager.default.isExecutableFile(atPath: result) { return result }
        }
        if ["clang", "clang++", "gcc", "g++"].contains(tool) {
            if let xcrunPath = try? await shell("xcrun", ["-f", tool]), !xcrunPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let result = xcrunPath.trimmingCharacters(in: .whitespacesAndNewlines)
                if FileManager.default.isExecutableFile(atPath: result) { return result }
            }
        }
        if let custom = findToolInCommonPaths(tool: tool) {
            return custom
        }
        return nil
    }
    
    func findToolInCommonPaths(tool: String) -> String? {
        let prefixes = [
            "/opt/homebrew/bin",
            "/usr/local/bin",
            "/usr/bin",
            "/bin",
            "/opt/local/bin"
        ]
        for dir in prefixes {
            let candidate = "\(dir)/\(tool)"
            if FileManager.default.isExecutableFile(atPath: candidate) {
                return candidate
            }
        }
        return nil
    }

    func shell(_ launchPath: String, _ arguments: [String]) async throws -> String {
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = [launchPath] + arguments
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8) ?? ""
    }

    func browseForTool(completion: @escaping (String?) -> Void, setName: @escaping (String) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.title = "Seleziona il file eseguibile"
        panel.prompt = "Scegli"
        panel.allowedContentTypes = [.executable]
        panel.directoryURL = URL(fileURLWithPath: "/usr/bin")
        panel.begin { result in
            if result == .OK, let url = panel.url {
                completion(url.path)
                setName(url.lastPathComponent)
            } else {
                completion(nil)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Compiler Paths")
                .font(.title)
            
            VStack(spacing: 17) {
                PathSelectorRow(
                    title: "C Compiler (GCC/Clang)",
                    path: $cCompiler.path,
                    isLoading: cCompiler.isLoading,
                    isWarning: cCompiler.notFound,
                    onBrowse: {
                        browseForTool(
                            completion: { if let path = $0 { cCompiler.path = path } },
                            setName: { cCompilerName = $0 }
                        )
                    }
                )
                
                PathSelectorRow(
                    title: "C++ Compiler (G++/Clang++)",
                    path: $cppCompiler.path,
                    isLoading: cppCompiler.isLoading,
                    isWarning: cppCompiler.notFound,
                    onBrowse: {
                        browseForTool(
                            completion: { if let path = $0 { cppCompiler.path = path } },
                            setName: { cppCompilerName = $0 }
                        )
                    }
                )
                
                PathSelectorRow(
                    title: "Make",
                    path: $make.path,
                    isLoading: make.isLoading,
                    isWarning: make.notFound,
                    onBrowse: {
                        browseForTool(
                            completion: { if let path = $0 { make.path = path } },
                            setName: { makeName = $0 }
                        )
                    }
                )
                
                PathSelectorRow(
                    title: "CMake",
                    path: $cmake.path,
                    isLoading: cmake.isLoading,
                    isWarning: cmake.notFound,
                    onBrowse: {
                        browseForTool(
                            completion: { if let path = $0 { cmake.path = path } },
                            setName: { cmakeName = $0 }
                        )
                    }
                )
                
                PathSelectorRow(
                    title: "Ninja",
                    path: $ninja.path,
                    isLoading: ninja.isLoading,
                    isWarning: ninja.notFound,
                    onBrowse: {
                        browseForTool(
                            completion: { if let path = $0 { ninja.path = path } },
                            setName: { ninjaName = $0 }
                        )
                    }
                )
            }
            .padding()
            .background(backgroundView)
            .padding(.top, 17)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Save") {
                    compilerProfile.updateProfile(profile: CompileProfile(
                        compilerCPath: cCompiler.path,
                        compilerCName: cCompilerName,
                        compilerCppPath: cppCompiler.path,
                        compilerCppName: cppCompilerName,
                        cmakePath: cmake.path,
                        cmakeName: cmakeName,
                        ninjaPath: ninja.path,
                        ninjaName: ninjaName,
                        makePath: make.path,
                        makeName: makeName
                    ))
                    
                    navigationState.navigationItem.principalNavigation = .HOME
                }
                .buttonStyle(.glassProminent)
                .disabled(
                    (cCompiler.path == "" || cCompiler.path == "Not found") &&
                    (cppCompiler.path == "" || cppCompiler.path == "Not found") &&
                    (make.path == "" || make.path == "Not found") &&
                    (cmake.path == "" || cmake.path == "Not found") &&
                    (ninja.path == "" || ninja.path == "Not found")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(15)
        .onAppear(perform: {
            if cCompiler.isLoading || cppCompiler.isLoading || make.isLoading || cmake.isLoading || ninja.isLoading {
                startAllLookups()
            }
        })
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 4)
    }
}
