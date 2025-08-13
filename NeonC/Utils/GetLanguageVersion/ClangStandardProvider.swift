//
//  ClangStandardProvider.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation

protocol StandardsProvider {
    func loadDisplayStandards() async -> [String]
    func loadCmakeVersion() async -> String
}

final class ClangStandardsProvider: StandardsProvider {
    static let shared = ClangStandardsProvider()
    private var cacheLanguage: [String]?
    private var cacheCmake: String?
    private init() {}

    func loadDisplayStandards() async -> [String] {
        if let cacheLanguage { return cacheLanguage }
        
        let result = await Task.detached(priority: .userInitiated) { () -> [String] in
            let lower = await standardsForCurrentClang()
            return await displayStandards(lower)
        }.value
        
        cacheLanguage = result
        return result
    }
    
    func loadCmakeVersion() async -> String {
        if let cacheCmake { return cacheCmake }
        
        let result = await Task.detached(priority: .userInitiated) { () -> String in
            return await getCmakeVersion()
        }.value
        
        return result
    }
}

/// Cmake version
private func getCmakeVersion() -> String {

    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        return "4.0"
    }
    
    let res = runCommand("/opt/homebrew/bin/cmake", ["cmake", "--version"])
    let combined = (res.stdout + "\n" + res.stderr)
    
    let lines = combined.split(separator: "\n").map { String($0) }
    let candidateLine = lines.first { $0.lowercased().contains("cmake") && $0.lowercased().contains("version") } ?? lines.first
    
    guard let line = candidateLine else { return "" }
    
    let primaryPattern = #"cmake\s+version\s*([0-9]+(?:\.[0-9]+){0,2})"#
    let fallbackPattern = #"([0-9]+(?:\.[0-9]+){0,2})"#
    
    let nsLine = line as NSString
    if let regex = try? NSRegularExpression(pattern: primaryPattern, options: .caseInsensitive),
       let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: nsLine.length)),
       match.numberOfRanges >= 2 {
        let found = nsLine.substring(with: match.range(at: 1))
        return normalizeVersion(found)
    }
    
    if let regex2 = try? NSRegularExpression(pattern: fallbackPattern, options: .caseInsensitive),
       let match2 = regex2.firstMatch(in: line, options: [], range: NSRange(location: 0, length: nsLine.length)),
       match2.numberOfRanges >= 2 {
        let found = nsLine.substring(with: match2.range(at: 1))
        return normalizeVersion(found)
    }
    
    return ""
}

private func normalizeVersion(_ v: String) -> String {
    let parts = v.split(separator: ".").map { String($0) }
    var nums: [Int] = []
    for p in parts {
        if let n = Int(p) { nums.append(n) } else { break }
    }
    if nums.count == 0 { return v } // fallback
    while nums.count < 3 { nums.append(0) } // pad to major.minor.patch
    return "\(nums[0]).\(nums[1]).\(nums[2])"
}

/// Clang support language
private func standardsForCurrentClang() -> [String] {
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        if let cfg = loadClangCompatFromBundle() {
            return cfg.default.filter { $0.hasPrefix("c") }
        }
        return ["c90","c99","c11","c17"]
    }

    let cfg = loadClangCompatFromBundle()
    if let major = clangMajorVersion(), let cfg = cfg {

        if let range = cfg.ranges.first(where: { item in
            let minOk = major >= item.min
            let maxOk = item.max.map { major <= $0 } ?? true
            return minOk && maxOk
            
        }) {
            return Array(Set(range.standards)).filter { $0.hasPrefix("c") }.sorted()
            
        } else {
            return cfg.default.filter { $0.hasPrefix("c") }
            
        }
        
    } else {
        if let cfg = cfg {
            return cfg.default.filter { $0.hasPrefix("c") }
        }
        
        return ["c90","c99","c11","c17"]
    }
}

private func loadClangCompatFromBundle() -> ClangCompat? {
    guard let url = Bundle.main.url(forResource: "clang-versions", withExtension: "json") else {
        return nil
    }
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(ClangCompat.self, from: data)
        
    } catch {
        print("Errore decoding clang-versions.json:", error)
        return nil
        
    }
}

private func clangMajorVersion() -> Int? {
    let res = runCommand("/usr/bin/env", ["clang", "--version"])
    let combined = (res.stdout + "\n" + res.stderr).lowercased()
    let pattern = #"clang\s+version\s+([0-9]{1,3})\."#
    
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let nsString = combined as NSString
        
        if let match = regex.firstMatch(in: combined, options: [], range: NSRange(location: 0, length: nsString.length)), match.numberOfRanges >= 2 {
            
            let majorStr = nsString.substring(with: match.range(at: 1))
            return Int(majorStr)
            
        }
        
    } catch {
        print("Error regex: \(error)")
    }
    
    return nil
}

private func displayStandards(_ lowercased: [String]) -> [String] {
    let ordering = ["c90","c99","c11","c17","c23","c2x"]
    let unique = Array(Set(lowercased))
    let sorted = unique.sorted { a, b in
        let ia = ordering.firstIndex(of: a) ?? Int.max
        let ib = ordering.firstIndex(of: b) ?? Int.max
        if ia != ib { return ia < ib }
        return a < b
        
    }
    return sorted.map { $0.uppercased() }
}

@discardableResult
private func runCommand(_ executable: String, _ args: [String]) -> (stdout: String, stderr: String, exitCode: Int32) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = args

    let outPipe = Pipe()
    let errPipe = Pipe()
    process.standardOutput = outPipe
    process.standardError = errPipe

    do { try process.run() } catch {
        return ("", "\(error)", -1)
    }

    process.waitUntilExit()

    let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
    let stdout = String(data: outData, encoding: .utf8) ?? ""
    let stderr = String(data: errData, encoding: .utf8) ?? ""
    return (stdout, stderr, process.terminationStatus)
}
