//
//  LSPDiagnostic.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

import Foundation
struct LSPDiagnostic {
    let range: NSRange
    let severity: Severity
    let message: String

    enum Severity: Int {
        case error = 1, warning = 2, info = 3, hint = 4
        
    }

    init?(from dict: [String: Any], inText text: String) {
        
        guard
            let rangeDict = dict["range"] as? [String: Any],
            let startDict = rangeDict["start"] as? [String: Any],
            let endDict   = rangeDict["end"] as? [String: Any],
            let startLine = startDict["line"] as? Int,
            let startChar = startDict["character"] as? Int,
            let endLine   = endDict["line"] as? Int,
            let endChar   = endDict["character"] as? Int,
            let message   = dict["message"] as? String
                
        else {
            print("LSPDiagnostic: failed to parse diagnostic dict: \(dict)")
            return nil
            
        }

        let nsRange = text.nsRangeFrom(lspStartLine: startLine, lspStartCharacter: startChar, lspEndLine: endLine, lspEndCharacter: endChar)
        
        self.range = nsRange
        self.severity = Severity(rawValue: dict["severity"] as? Int ?? 1) ?? .error
        self.message = message
    }
}
