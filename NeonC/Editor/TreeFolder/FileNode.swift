//
//  FileNode.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI
import Foundation
internal import Combine

import AppKit

final class FileNode: ObservableObject, Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let isDirectory: Bool

    @Published var children: [FileNode] = []
    @Published var isExpanded: Bool = false
    @Published var icon: Image? = nil

    private var loaded = false

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        
        self.isDirectory = isDir.boolValue
        
        loadIcon()
    }

    func loadChildren() {
        guard isDirectory, !loaded else { return }
        
        loaded = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fm = FileManager.default
            let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
            var items: [FileNode] = []
            
            if let content = try? fm.contentsOfDirectory(at: self.url, includingPropertiesForKeys: [.isDirectoryKey], options: options) {
                let sorted = content.sorted { a, b in
                    
                    let aa = (try? a.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    let bb = (try? b.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
                    if aa == bb {
                        return a.lastPathComponent.lowercased() < b.lastPathComponent.lowercased()
                        
                    }
                    return aa && !bb
                    
                }
                items = sorted.map { FileNode(url: $0) }
            }
            
            DispatchQueue.main.async {
                self.children = items
            }
            
        }
    }

    private func loadIcon() {
        let nsIcon = NSWorkspace.shared.icon(forFile: url.path)
        
        nsIcon.size = NSSize(width: 14, height: 14)
        self.icon = Image(nsImage: nsIcon)
        
    }
}
