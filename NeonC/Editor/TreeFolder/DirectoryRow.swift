//
//  DirectoryRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct DirectoryRow: View {
    @ObservedObject var node: FileNode
    var level: Int
    var onOpenFile: ((URL) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                if node.isDirectory {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        node.isExpanded.toggle()
                        
                        if node.isExpanded { node.loadChildren() }
                        
                    }
                    
                } else {
                    onOpenFile?(node.url)
                    
                }
                
            }) {
                HStack(spacing: 6) {
                    Color.clear.frame(width: CGFloat(level) * 14, height: 1)

                    if node.isDirectory {
                        Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                            .frame(width: 12, height: 12)
                            .imageScale(.small)
                        
                    } else {
                        Color.clear.frame(width: 12, height: 12)
                        
                    }

                    if let icon = node.icon {
                        icon
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                    } else {
                        Image(systemName: node.isDirectory ? "folder" : "doc.text")
                            .frame(width: 14, height: 14)
                        
                    }

                    Text(node.name.isEmpty ? node.url.path : node.name)
                        .font(.system(size: 13))
                        .lineLimit(1)
                    
                    Spacer()
                    
                }
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())

            }
            .buttonStyle(PlainButtonStyle())
            
            if node.isDirectory && node.isExpanded {
                ForEach(node.children) { child in
                    DirectoryRow(node: child, level: level + 1, onOpenFile: onOpenFile)
                                        
                }
                
            }
        }
    }
}
