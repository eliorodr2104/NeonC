//
//  IconCache.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/08/25.
//

import AppKit
import UniformTypeIdentifiers

final class IconCache {
    static let shared = IconCache()
    private var cache: [String: NSImage] = [:]
    private let lock = NSLock()
    
    func icon(for url: URL? = nil, lang: TypeProject? = nil, fileType: FileType? = nil) -> NSImage {

        let key: String
        if let url = url {
            key = url.path
            
        } else if let lang = lang {
            key = "lang:\(lang.projectExtension)"
            
        } else if let fileType = fileType {
            key = "file_type:\(fileType.fileExtension)"
            
        } else {
            key = "default"
            
        }
        
        lock.lock()
        if let cached = cache[key] {
            lock.unlock()
            
            return cached
        }
        lock.unlock()
        
        let icon: NSImage
        if let lang = lang, let utType = UTType(filenameExtension: lang.projectExtension) {
            icon = NSWorkspace.shared.icon(for: utType)
            
        } else if let fileType = fileType, let utType = UTType(filenameExtension: fileType.fileExtension) {
            icon = NSWorkspace.shared.icon(for: utType)
            
        } else if let url = url {
            icon = NSWorkspace.shared.icon(forFile: url.path)
            
        } else {
            icon = NSImage(systemSymbolName: "doc", accessibilityDescription: nil)!
            
        }
        
        lock.lock()
        cache[key] = icon
        lock.unlock()
        
        return icon
    }
}
