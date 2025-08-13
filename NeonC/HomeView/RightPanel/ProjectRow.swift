//
//  ProjectRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ProjectRow: View {
    let project: RecentProject
    var onSelect: () -> Void
    var onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        
        Button(action: onSelect) {
            HStack(spacing: 10) {
                
                ZStack {
                    // Add color system for varius project Type
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.primary.opacity(0.10))
                        .frame(width: 45, height: 45)
                    
                    Image(systemName: "folder")
                        .foregroundStyle(.placeholder)
                        .font(.title3)
                        .padding(.vertical, 6)
                    
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(project.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    HStack {
                        
                        Image(systemName: "calendar")
                            .foregroundStyle(.placeholder)
                            .font(.headline)
                            .padding(.vertical, 6)
                        
                        Text("add last openened! ")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        ZStack {
                            Capsule()
                                .fill(.primary.opacity(0.10))
                                .frame(width: 35, height: 25)
                            
                            Image("c")
                                .font(.headline)
                                .padding(.vertical, 6)
                        }
                    }
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .opacity(isHovering ? 1 : 0)
            }
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isHovering ? .accentColor.opacity(0.08) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(isHovering ? .accentColor.opacity(0.02) : Color.clear, lineWidth: 1)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        
    }
}

