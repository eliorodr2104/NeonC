//
//  ModalityBoxView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ModalityBoxView: View {
    @State private var isHovering = false
    let currentModality: CreationModalityItem
    
    init(currentModality: CreationModalityItem) {
        self.currentModality = currentModality
        
    }
    
    var body: some View {
            Button(action: {
                
                
            }) {
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Image(systemName: currentModality.icon)
                        .font(.title3)
                        .padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentModality.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(currentModality.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }

                    Spacer()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.buttonBorder)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isHovering ? Color.accentColor.opacity(0.09) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(isHovering ? Color.accentColor.opacity(0.18) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(.automatic)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.12)) {
                    isHovering = hovering
                }
            }
        }
}
