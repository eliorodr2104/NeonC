//
//  ListFiles.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/08/25.
//

import SwiftUI

struct ListFilesView: View {
    
    @ObservedObject private var viewModel: FileSearchViewModel
    @Binding        private var selectedListIndex: Int
    var onSelect: (FileItem) -> Void
    
    init(viewModel: FileSearchViewModel, selectedListIndex: Binding<Int>, onSelect: @escaping (FileItem) -> Void) {
        self.viewModel          = viewModel
        self._selectedListIndex = selectedListIndex
        self.onSelect           = onSelect
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                VStack(spacing: 0) {
                    ForEach(viewModel.results.indices, id: \.self) { index in
                        let item = viewModel.results[index]
                        
                        HStack(alignment: .center, spacing: 12) {
                            Image(nsImage: IconCache.shared.icon(for: item.url, lang: nil))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            
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
                        .background(index == selectedListIndex ? Color.accentColor.opacity(0.15) : Color.clear)
                        .cornerRadius(8)
                        .id(index)
                        .onTapGesture {
                            selectedListIndex = index
                            onSelect(item)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            .onChange(of: selectedListIndex) { _, newIndex in
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
