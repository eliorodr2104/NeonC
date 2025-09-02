//
//  ProjectCreator.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation

enum ProjectCreationError: Error, LocalizedError {
    case invalidProjectName
    case projectAlreadyExists(URL)
    case templateNotFound(String)
    case writeFailed(URL)
    case bundleReadFailed(URL)

    var errorDescription: String? {
        switch self {
        case .invalidProjectName:
            return "This name is not valid."
            
        case .projectAlreadyExists(let url):
            return "The folder is alredy exists: \(url.path)"
            
        case .templateNotFound(let name):
            return "Not found template in bundle: \(name)"
            
        case .writeFailed(let url):
            return "Write is failed: \(url.path)"
            
        case .bundleReadFailed(let url):
            return "Read bundle file is filed: \(url.path)"
            
        }
    }
}

actor ProjectCreator {
    static let shared = ProjectCreator()

    func createProject(
        at baseDirectory: URL,
        name projectName: String,
        cmakeVersion: String,
        kind: ProjectKind,
        standard: String
    ) async throws -> URL {

        let trimmedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw ProjectCreationError.invalidProjectName }

        let projectDir = baseDirectory.appendingPathComponent(trimmedName, isDirectory: true)
        let srcDir = projectDir.appendingPathComponent("src", isDirectory: true)
        let includeDir = projectDir.appendingPathComponent("include", isDirectory: true)

        if FileManager.default.fileExists(atPath: projectDir.path) {
            throw ProjectCreationError.projectAlreadyExists(projectDir)
        }

        try FileManager.default.createDirectory(at: srcDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: includeDir, withIntermediateDirectories: true)

        let language = await kind.language.cmakeLanguage
        let mainFileName = await kind.language.mainFileName
        let sources = ["src/\(mainFileName)"]
        let standardValue = standard

        // CMakeLists.txt to template
        let cmakeTemplate = try loadTemplateText(resourceName: "CMakeLists.txt", extension: "template")
        let cmakeFilled = await replacePlaceholders(
            in: cmakeTemplate,
            with: [
                "project_name": trimmedName,
                "cmake_version": cmakeVersion,
                "language": language,
                "standard": standardValue,
                "source": mainFileName,
                "target_declaration": kind.targetDeclaration(projectName: trimmedName, sources: sources)
            ]
        )

        let cmakeURL = projectDir.appendingPathComponent("CMakeLists.txt")
        try writeText(cmakeFilled, to: cmakeURL)

        let mainTemplateName: String
        switch await kind.language {
        case .c:   mainTemplateName = "main.c"
        case .cpp: mainTemplateName = "main.cpp"
        }

        let mainTemplate = try loadTemplateTextWithFallback(
            preferredName: mainTemplateName,
            fallbackName: "main.c",
            extension: "template"
        )
        
        let mainURL = srcDir.appendingPathComponent(mainFileName)
        try writeText(mainTemplate, to: mainURL)

        return projectDir
    }

    // MARK: - Helpers

    private func loadTemplateText(resourceName: String, extension ext: String) throws -> String {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: ext) else {
            throw ProjectCreationError.templateNotFound("\(resourceName).\(ext)")
        }
        do {
            let data = try Data(contentsOf: url)
            guard let text = String(data: data, encoding: .utf8) else {
                throw ProjectCreationError.bundleReadFailed(url)
            }
            return text
        } catch {
            throw ProjectCreationError.bundleReadFailed(url)
        }
    }

    private func loadTemplateTextWithFallback(preferredName: String, fallbackName: String, extension ext: String) throws -> String {
        if let url = Bundle.main.url(forResource: preferredName, withExtension: ext),
           let data = try? Data(contentsOf: url),
           let text = String(data: data, encoding: .utf8) {
            return text
        }
        // Fallback
        guard let url = Bundle.main.url(forResource: fallbackName, withExtension: ext) else {
            throw ProjectCreationError.templateNotFound("\(preferredName).\(ext) / fallback \(fallbackName).\(ext)")
        }
        do {
            let data = try Data(contentsOf: url)
            guard let text = String(data: data, encoding: .utf8) else {
                throw ProjectCreationError.bundleReadFailed(url)
            }
            return text
        } catch {
            throw ProjectCreationError.bundleReadFailed(url)
        }
    }

    private func replacePlaceholders(in template: String, with values: [String: String]) -> String {
        var result = template
        for (key, value) in values {
            let token = "{{\(key)}}"
            result = result.replacingOccurrences(of: token, with: value)
        }
        return result
    }

    private func writeText(_ text: String, to url: URL) throws {
        do {
            try text.data(using: .utf8)?.write(to: url, options: [.atomic])
        } catch {
            throw ProjectCreationError.writeFailed(url)
        }
    }
}
