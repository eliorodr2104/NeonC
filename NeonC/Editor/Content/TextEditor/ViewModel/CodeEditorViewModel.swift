//
//  CodeEditorViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//
import Foundation
import AppKit
internal import Combine
import SwiftUI

final class CodeEditorViewModel: ObservableObject {
    @Published private(set) var diagnostics: [LSPDiagnostic] = []
    
    var projectRoot: URL
    var documentURI: URL

    
    private var textView                : NSTextView?
    private var scrollView              : NSScrollView?
    private var lspClient               : LSPClient?
    private var cancellables            : Set<AnyCancellable> = Set<AnyCancellable>()
    private var lastVersion             : Int                 = 1
    private let highlightQueue          : DispatchQueue       = DispatchQueue(label: "syntax.highlight", qos: .userInitiated)
    private let highlightDebounceSeconds: TimeInterval        = 0.12
    private var pendingHighlightWorkItem: DispatchWorkItem?

    init(projectRoot: URL, documentURI: URL) {
        self.projectRoot = projectRoot
        self.documentURI = documentURI
        
    }

    func setupLSP(language: Language) {
        lspClient = LSPClient()
        
        try? lspClient?.start(projectRoot: projectRoot)

        NotificationCenter.default.publisher(for: .lspDiagnosticsReceived)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                self?.handleDiagnostics(notification)
            }
            .store(in: &cancellables)

        lspClient?.openDocument(uri: documentURI.absoluteString, languageId: language.lspID, text: textView?.string ?? "")
        
    }

    func textChanged(newText: String) {
        guard let lsp = lspClient else { return }
        
        lastVersion += 1
        lsp.changeDocument(uri: documentURI.absoluteString, text: newText, version: lastVersion)
        
        scheduleHighlight()
    }

    private func handleDiagnostics(_ notification: Notification) {
        guard let obj = notification.object as? [String: Any],
              let params = obj["params"] as? [String: Any],
              let uri = params["uri"] as? String,
              uri == documentURI.absoluteString,
              let diagnosticsArray = params["diagnostics"] as? [[String: Any]] else {
            return
        }

        let currentText  = textView?.string ?? ""
        self.diagnostics = diagnosticsArray.compactMap { LSPDiagnostic(from: $0, inText: currentText) }

        scheduleHighlight()
    }

    private func scheduleHighlight() {

        pendingHighlightWorkItem?.cancel()

        let captureVersion = lastVersion
        let captureText = textView?.string ?? ""
        let captureDiagnostics = diagnostics

        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            let semanticTokens: [SyntaxHighlighter.SemanticToken] = []

            let instructions = SyntaxHighlighter.shared.computeHighlightInstructions(
                text: captureText,
                diagnostics: captureDiagnostics,
                semanticTokens: semanticTokens
            )

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.lastVersion == captureVersion {
                    if let tv = self.textView {
                        SyntaxHighlighter.shared.applyHighlightInstructions(textView: tv, instructions: instructions)
                        
                    }
                    
                }
            }
        }

        pendingHighlightWorkItem = work
        highlightQueue.asyncAfter(deadline: .now() + highlightDebounceSeconds, execute: work)
        
    }

    func createTextView(text: String) -> NSScrollView {
        if let existing = scrollView {
            updateTextView(existing, text: text)
            
            return existing
        }
        
        // Settings Editor

        let sv = NSScrollView()
        
        sv.hasVerticalScroller   = true
        sv.hasHorizontalScroller = false
        sv.drawsBackground       = false
        sv.backgroundColor       = .clear
        sv.autoresizingMask      = [.width, .height]

        let tv = NSTextView(frame: sv.bounds)
        
        tv.isEditable = true
        tv.isRichText = false
        tv.isAutomaticQuoteSubstitutionEnabled = false
        tv.isAutomaticLinkDetectionEnabled = false
        tv.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        tv.allowsUndo = true
        
        tv.drawsBackground = false
        tv.backgroundColor = .clear
        
        tv.textColor = NSColor.textColor
        tv.string = text

        tv.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        tv.textContainer?.widthTracksTextView = true
        tv.isHorizontallyResizable = false
        tv.isVerticallyResizable = true
        tv.autoresizingMask = [.width]

        textView = tv
        sv.documentView = tv
        scrollView = sv

        scheduleHighlight()

        return sv
    }

    func updateTextView(_ scrollView: NSScrollView, text: String) {
        guard let tv = scrollView.documentView as? NSTextView else { return }
        
        if tv.string == text { return }

        let selectedRanges = tv.selectedRanges
        let scrollPosition = tv.enclosingScrollView?.contentView.bounds.origin ?? .zero

        if let storage = tv.textStorage {
            storage.beginEditing()
            
            let fullRange = NSRange(location: 0, length: storage.length)
            storage.replaceCharacters(in: fullRange, with: text)
            storage.endEditing()
            
        } else {
            tv.string = text
            
        }

        if !selectedRanges.isEmpty {
            tv.selectedRanges = selectedRanges
            
        }

        if let sv = tv.enclosingScrollView {
            sv.contentView.scroll(to: scrollPosition)
            sv.reflectScrolledClipView(sv.contentView)
            
        }

        textView = tv
        scheduleHighlight()
    }
}

extension Notification.Name {
    static let lspDiagnosticsReceived = Notification.Name("LSPDiagnosticsReceived")
}

