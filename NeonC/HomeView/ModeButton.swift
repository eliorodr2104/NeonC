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
                iconContainer
                textContainer
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(interactiveBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var iconContainer: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(.primary.opacity(0.10))
                .frame(width: 45, height: 45)

            Image(systemName: currentMode.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
        }
    }

    private var textContainer: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(currentMode.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(currentMode.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var interactiveBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(backgroundFill)
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }

    private var backgroundFill: Color {
        if isHovering {
            return .accentColor.opacity(0.08)
        } else {
            return .clear
        }
    }

    private var borderColor: Color {
        if isHovering {
            return .accentColor.opacity(0.2)
        } else {
            return .clear
        }
    }
}
