//
//  ModeButton.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct ModeButton: View {
    let currentMode: ModeItem
    @State private var isHovering = false

    var body: some View {
        
        Button(action: {
            currentMode.function()
            
        }) {
            HStack(alignment: .center, spacing: 12) {
                
                Image(systemName: currentMode.icon)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.accentColor.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(currentMode.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(currentMode.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(
                Capsule()
                    .fill(isHovering ? Color.accentColor.opacity(0.09) : Color.clear)
                    
            )
            .overlay(
                Capsule()
                    .strokeBorder(isHovering ? Color.accentColor.opacity(0.18) : Color.clear, lineWidth: 1)
            )

        }
        .buttonStyle(.glass)
        .buttonBorderShape(ButtonBorderShape.capsule)
        .onHover { hovering in
            isHovering = hovering
        }
        
    }
}
