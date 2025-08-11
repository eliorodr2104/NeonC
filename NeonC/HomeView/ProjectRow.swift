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
        HStack(spacing: 10) {
            Image(systemName: "folder")
                .foregroundStyle(.placeholder)
                .font(.title3)
                .padding(.vertical, 6)
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(project.path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
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
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHovering ? Color.accentColor.opacity(0.09) : Color.clear)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
        .contextMenu {
            Button("Open", action: onSelect)
            Divider()
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remove from Recents", systemImage: "trash")
            }
        }
    }
}

