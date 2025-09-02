//
//  ListCreationFile.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 25/08/25.
//

import SwiftUI

struct ListCreationFileView: View {
    @Binding private var indexSelect: Int
    
    private let files  : [CreationFile]
    private let columns: [GridItem]
    
    init(indexSelect: Binding<Int>) {
        
        self._indexSelect = indexSelect
        
        self.files = [
            CreationFile(name: "C File", lang: .c),
            CreationFile(name: "C++ File", lang: .cpp),
            CreationFile(name: "Header File", lang: .h)
        ]
        
        self.columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                
                ForEach(files.indices, id: \.self) { index in
                    let item = files[index]
                    
                    CreationFileView(
                        currentFile: item,
                        onAction: { /* Action Button */ }
                    )
                    .id(item.id)
                    .background(index == indexSelect ? Color.accentColor.opacity(0.15) : Color.clear)
                    .onTapGesture {
                        indexSelect = index
                    }
                }
            }
            .padding()
        }
        .frame(maxHeight: 300)
    }
}
