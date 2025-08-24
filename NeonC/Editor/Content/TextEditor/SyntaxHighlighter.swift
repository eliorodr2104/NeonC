//
//  SyntaxHighlighter.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//
import Foundation
import AppKit

final class SyntaxHighlighter {
    static let shared = SyntaxHighlighter()
    private init() {}

    struct SemanticToken {
        let range: NSRange
        let tokenType: String
    }

    typealias HighlightInstruction = (range: NSRange, attrs: [NSAttributedString.Key: Any])

    func computeHighlightInstructions(
        text          : String,
        diagnostics   : [LSPDiagnostic] = [],
        semanticTokens: [SemanticToken] = []
        
    ) -> [HighlightInstruction] {
        
        var instructions: [HighlightInstruction] = []

        let nsText = text as NSString
        let fullRange = NSRange(location: 0, length: nsText.length)
        if fullRange.length == 0 { return instructions }

        let defaultFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let boldFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .bold)

        let keywordColor      = NSColor.systemBlue
        let commentColor      = NSColor.systemGreen
        let stringColor       = NSColor.systemRed
        let numberColor       = NSColor.systemOrange
        let preprocessorColor = NSColor.systemPurple

        if !semanticTokens.isEmpty {
            
            for token in semanticTokens {
                
                guard token.range.location >= 0 && token.range.location + token.range.length <= fullRange.length else { continue }
                
                let attrs: [NSAttributedString.Key: Any]
                
                switch token.tokenType {
                    
                    case "keyword":
                        attrs = [.foregroundColor: keywordColor, .font: boldFont]
                    
                    case "function":
                        attrs = [.foregroundColor: NSColor.systemPink, .font: defaultFont]
                    
                    case "variable":
                        attrs = [.foregroundColor: NSColor.labelColor, .font: defaultFont]
                    
                    case "string":
                        attrs = [.foregroundColor: stringColor, .font: defaultFont]
                    
                    case "comment":
                        attrs = [.foregroundColor: commentColor, .font: defaultFont]
                    
                    default:
                        attrs = [.foregroundColor: NSColor.textColor, .font: defaultFont]
                }
                
                instructions.append((token.range, attrs))
            }
        }

        do {
            let keywords = [
                "int", "float", "double", "char", "void", "if", "else", "while", "for", "return",
                "struct", "class", "typedef", "switch", "case", "break", "continue", "const",
                "unsigned", "signed", "namespace", "public", "private", "protected", "virtual",
                "auto", "extern", "static", "register", "enum", "union", "goto", "default", "sizeof"
            ]

            for keyword in keywords {
                let pattern = "\\b" + NSRegularExpression.escapedPattern(for: keyword) + "\\b"
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let matches = regex.matches(in: text, range: fullRange)
                
                for match in matches {
                    let r = match.range
                    
                    let attrs: [NSAttributedString.Key: Any] = [
                        .foregroundColor: keywordColor,
                        .font: boldFont
                    ]
                    
                    instructions.append((r, attrs))
                }
            }
            
            let singleLineCommentRegex = try NSRegularExpression(pattern: "//[^\\n]*", options: [])
            for m in singleLineCommentRegex.matches(in: text, range: fullRange) {
                instructions.append((m.range, [.foregroundColor: commentColor, .font: defaultFont]))
                
            }

            let multiLineCommentRegex = try NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: [.dotMatchesLineSeparators])
            for m in multiLineCommentRegex.matches(in: text, range: fullRange) {
                instructions.append((m.range, [.foregroundColor: commentColor, .font: defaultFont]))
                
            }

            // Strings color
            let stringRegex = try NSRegularExpression(pattern: "\"([^\\\\\"]|\\\\.)*\"|'([^\\\\']|\\\\.)*'", options: [])
            for m in stringRegex.matches(in: text, range: fullRange) {
                instructions.append((m.range, [.foregroundColor: stringColor, .font: defaultFont]))
                
            }

            // Numbers color
            let numberRegex = try NSRegularExpression(pattern: "\\b0x[0-9a-fA-F]+\\b|\\b[0-9]+\\.[0-9]+\\b|\\b[0-9]+\\b", options: [])
            for m in numberRegex.matches(in: text, range: fullRange) {
                instructions.append((m.range, [.foregroundColor: numberColor, .font: defaultFont]))
                
            }

            // Preprocessor instruction color
            let preprocessorRegex = try NSRegularExpression(pattern: "^\\s*#\\w+.*$", options: .anchorsMatchLines)
            for m in preprocessorRegex.matches(in: text, range: fullRange) {
                instructions.append((m.range, [.foregroundColor: preprocessorColor, .font: defaultFont]))
                
            }

        } catch {
            print("SyntaxHighlighter compute error: \(error)")
            
        }

        // Diagnostics -> underline attributes color
        for diag in diagnostics {
            
            let r = diag.range
            
            if r.location >= 0 {
                let underlineColor: NSColor
                
                switch diag.severity {
                    case .error: underlineColor = .systemRed
                    case .warning: underlineColor = .systemOrange
                    case .info, .hint: underlineColor = .systemBlue
                }

                let attrs: [NSAttributedString.Key: Any] = [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: underlineColor
                ]
                
                instructions.append((r, attrs))
                
            }
        }

        return instructions
    }

    func applyHighlightInstructions(textView: NSTextView, instructions: [HighlightInstruction]) {
        
        guard let textStorage = textView.textStorage else { return }
        
        let text = textView.string as NSString
        let fullRange = NSRange(location: 0, length: text.length)
        if fullRange.length == 0 { return }

        textStorage.beginEditing()

        textStorage.removeAttribute(.foregroundColor, range: fullRange)
        textStorage.removeAttribute(.backgroundColor, range: fullRange)
        textStorage.removeAttribute(.underlineStyle, range: fullRange)
        textStorage.removeAttribute(.underlineColor, range: fullRange)
        textStorage.removeAttribute(.font, range: fullRange)

        let defaultFont = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let defaultAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.textColor,
            .font: defaultFont
        ]
        
        textStorage.addAttributes(defaultAttrs, range: fullRange)

        for instr in instructions {
            let r = instr.range
            
            if r.location >= 0 && r.location + r.length <= textStorage.length {
                textStorage.addAttributes(instr.attrs, range: r)
                
            }
        }

        textStorage.endEditing()
    }
}

/// String helpers (LSP line/char -> NSRange, UTF-16 safe)
extension String {
    
    func utf16OffsetOfLineStart(_ line: Int) -> Int {
        
        let ns = self as NSString
        var idx = 0
        var currentLine = 0
        
        while currentLine < line && idx < ns.length {
            
            let range = ns.range(of: "\n", options: [], range: NSRange(location: idx, length: ns.length - idx))
            
            if range.location == NSNotFound {
                idx = ns.length
                break
                
            } else {
                idx = range.location + 1
                currentLine += 1
                
            }
            
        }
        
        return idx
    }

    func nsRangeFrom(lspStartLine: Int, lspStartCharacter: Int, lspEndLine: Int, lspEndCharacter: Int) -> NSRange {
        let ns = self as NSString
        let startLineOffset = utf16OffsetOfLineStart(lspStartLine)
        let start = min(ns.length, startLineOffset + lspStartCharacter)

        let endLineOffset = utf16OffsetOfLineStart(lspEndLine)
        let end = min(ns.length, endLineOffset + lspEndCharacter)

        let length = max(0, end - start)
        
        return NSRange(location: start, length: length)
    }
}
