//
//  TreeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryTreeView: View {
    @StateObject private var rootNode: FileNode
    var onOpenFile: ((URL) -> Void)? = nil

    init(rootURL: URL, onOpenFile: ((URL) -> Void)? = nil) {
        _rootNode = StateObject(wrappedValue: FileNode(url: rootURL))
        self.onOpenFile = onOpenFile
        
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                DirectoryRow(node: rootNode, level: 0, onOpenFile: onOpenFile)
                
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            
        }
        .frame(minWidth: 220)
        .onAppear {
            if rootNode.isDirectory {
                rootNode.loadChildren()
                rootNode.isExpanded = true

            }
        }
    }
}
