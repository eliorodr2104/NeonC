//
//  FileSearchViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI
import AppKit
internal import Combine

struct FileItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
}

struct FileIconView: View {
    let url: URL
    var body: some View {
        let nsImage = NSWorkspace.shared.icon(forFile: url.path)
        Image(nsImage: nsImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
    }
}

class FileSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [FileItem] = []
    
    private var allFiles: [FileItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(directory: URL) {
        loadFiles(from: directory)
        
        $searchText
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.filterResults(for: query)
            }
            .store(in: &cancellables)
    }
    
    private func loadFiles(from directory: URL) {
        var files: [FileItem] = []
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if !fileURL.hasDirectoryPath {
                    files.append(FileItem(name: fileURL.lastPathComponent, url: fileURL))
                }
                
            }
        }
        
        self.allFiles = files
    }
    
    private func filterResults(for query: String) {
        if query.isEmpty {
            results = []
            
        } else {
            results = allFiles.filter { $0.name.localizedCaseInsensitiveContains(query) }
            
        }
    }
}
