//
//  ContextView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 15/08/25.
//

import SwiftUI

struct ContextView: View {
    
    let selectedFile: URL?
    @State private var isBottomVisible: Bool = true
    
    private let collapsedHeight: CGFloat = 48
    
    var body: some View {
        GeometryReader { geo in
            
            VStack(spacing: 10) {

                VStack {
                    if let selectedFile = selectedFile {
                        Text("Selected: \(selectedFile.lastPathComponent)")
                        
                    } else {
                        Text("Select a file to edit")
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: isBottomVisible ? geo.size.height * 0.75 : geo.size.height - collapsedHeight,
                    alignment: .topLeading
                )
                .background(roundedBackground)
                
                VStack(spacing: 0) {
                    
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Button {
                            withAnimation(.spring()) {
                                isBottomVisible.toggle()
                                
                            }
                            
                        } label: {
                            Image(systemName: "dock.rectangle")
                                .foregroundColor(isBottomVisible ? .accentColor : .primary)
                                
                        }
                        .buttonStyle(.plain)
                        
                    }
                    
                    .zIndex(1)
                    
                    if isBottomVisible {
                        Spacer()
                    }
                    
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    maxHeight: isBottomVisible ? geo.size.height * 0.25 : collapsedHeight,
                    alignment: .top
                )
                .background(roundedBackgroundTerminal)
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 16)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
            .animation(.spring(), value: isBottomVisible)
        }
    }
    
    private var roundedBackground: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
    
    private var roundedBackgroundTerminal: some View {
        RoundedRectangle(cornerRadius: isBottomVisible ? 26 : 20)
            .fill(.windowBackground)
            .stroke(.secondary.opacity(0.23), style: .init(lineWidth: 1))
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
}
