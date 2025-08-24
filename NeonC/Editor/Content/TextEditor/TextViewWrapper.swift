//
//  TextViewWrapper.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//
import SwiftUI
import AppKit

struct TextViewWrapper: NSViewRepresentable {
    @Binding var text     : String
             var viewModel: CodeEditorViewModel
             var language : Language

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = viewModel.createTextView(text: text)
        
        if let textView = scrollView.documentView as? NSTextView {
            textView.delegate = context.coordinator
            context.coordinator.textView = textView
            
        }
        
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        if textView.delegate == nil {
            textView.delegate = context.coordinator
            
        }
        
        context.coordinator.textView = textView
        
        if textView.string != text && !context.coordinator.isUpdatingText {
            context.coordinator.updateTextPreservingSelection(newText: text)
            
        }
        
    }

    class Coordinator: NSObject, NSTextViewDelegate {
             var parent  : TextViewWrapper
        weak var textView: NSTextView?
             var isUpdatingText = false
             var lastString     = ""

        init(_ parent: TextViewWrapper) { self.parent = parent }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            isUpdatingText = true
            
            defer { isUpdatingText = false }

            let newText = textView.string
            if parent.text != newText {
                parent.text = newText
                parent.viewModel.textChanged(newText: newText)
                
            }
            
            lastString = newText
        }

        func updateTextPreservingSelection(newText: String) {
            guard let textView = textView else { return }
            
            isUpdatingText = true
            
            defer { isUpdatingText = false }

            let selectedRanges = textView.selectedRanges
            let scrollPosition = textView.enclosingScrollView?.contentView.bounds.origin ?? .zero

            if let storage = textView.textStorage {
                storage.beginEditing()
                let fullRange = NSRange(location: 0, length: storage.length)
                
                storage.replaceCharacters(in: fullRange, with: newText)
                storage.endEditing()
                
            } else {
                textView.string = newText
                
            }

            if let firstRange = selectedRanges.first as? NSRange {
                
                let nsNewText = newText as NSString
                let newLen = nsNewText.length
                let location = min(firstRange.location, newLen)
                let length = min(firstRange.length, max(0, newLen - location))
                let safeRange = NSRange(location: location, length: length)
                
                textView.setSelectedRange(safeRange)
                
            }

            if let sv = textView.enclosingScrollView {
                sv.contentView.scroll(to: scrollPosition)
                sv.reflectScrolledClipView(sv.contentView)
                
            }

            lastString = newText
            
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                let currentRange = textView.selectedRange()
                let text = textView.string as NSString
                let lineRange = text.lineRange(for: NSRange(location: currentRange.location, length: 0))
                let currentLine = text.substring(with: lineRange)

                var indentation = ""
                
                for ch in currentLine {
                    if ch == " " || ch == "\t" { indentation.append(ch) }
                    else { break }
                    
                }

                textView.insertText("\n" + indentation, replacementRange: currentRange)
                return true
                
            }
            
            return false
        }
    }
}
