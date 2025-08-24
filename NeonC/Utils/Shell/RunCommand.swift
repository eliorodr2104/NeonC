//
//  RunCommands.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 22/08/25.
//

import Foundation

/// This func run command on pc shell
@discardableResult
func runCommand(_ executable: String, _ args: [String]) -> (stdout: String, stderr: String, exitCode: Int32) {
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
