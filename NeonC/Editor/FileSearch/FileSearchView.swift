//
//  FileSearchView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 24/08/25.
//

import SwiftUI

struct FileSearchView: View {
    @ObservedObject private var viewModel: FileSearchViewModel
    var onSelect: (FileItem) -> Void
    
    @State private var selectedIndex: Int = 0
    @State private var showResults: Bool = false
    
    init(directory: URL, onSelect: @escaping (FileItem) -> Void) {
        self.viewModel = FileSearchViewModel(directory: directory)
        self.onSelect = onSelect
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                
                TextField("Cerca file...", text: $viewModel.searchText)
                    .font(.system(size: 22, weight: .medium))
                    .textFieldStyle(.plain)
                    .onSubmit { selectCurrent() }
                    .background(Color.clear)
            
                if showResults {
                    
                    Divider() // Fino A Ieri -- Drast
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.results.indices, id: \.self) { index in
                                    let item = viewModel.results[index]
                                    
                                    HStack(alignment: .center, spacing: 12) {
                                        FileIconView(url: item.url)
                                        
                                        VStack(alignment: .leading) {
                                            Text(item.name)
                                                .font(.headline)
                                            
                                            Text(item.url.deletingLastPathComponent().path)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                    .padding(10)
                                    .background(index == selectedIndex ? Color.accentColor.opacity(0.15) : Color.clear)
                                    .cornerRadius(8)
                                    .id(index)
                                    .onTapGesture {
                                        selectedIndex = index
                                        onSelect(item)
                                    }
                                }
                            }
                            
                        }
                        .frame(maxHeight: 300)
                        .onChange(of: selectedIndex) { _, newIndex in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.95, anchor: .top)
                                .combined(with: .opacity)
                                .combined(with: .offset(y: -10)),
                            
                            removal: .scale(scale: 0.95, anchor: .top)
                                .combined(with: .opacity)
                                .combined(with: .offset(y: -10))
                        )
                    )
                }
                            
            }
            .padding()
            .frame(maxWidth: 600)
            .glassEffect(in: .rect(cornerRadius: 36))
            .onKeyPress { keyPress in
                guard !viewModel.results.isEmpty else { return .ignored }
                
                switch keyPress.key {
                case .downArrow:
                    if selectedIndex < viewModel.results.count - 1 {
                        selectedIndex += 1
                    }
                    return .handled
                    
                case .upArrow:
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                    return .handled
                    
                case .return:
                    selectCurrent()
                    return .handled
                    
                case .escape:
                    return .handled
                    
                default:
                    return .ignored
                }
            }
            .onChange(of: viewModel.results) {
                selectedIndex = 0
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                    showResults = !viewModel.results.isEmpty && viewModel.searchText != ""
                }
            }
            
            Spacer()
            
        }
        .padding(.top, 40)
    }
    
    private func selectCurrent() {
        guard !viewModel.results.isEmpty else { return }
        onSelect(viewModel.results[selectedIndex])
    }
}
