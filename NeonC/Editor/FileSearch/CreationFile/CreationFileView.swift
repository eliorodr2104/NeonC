//
//  CreationFileIcon.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 28/08/25.
//

import SwiftUI

struct CreationFileView: View {
    
    let currentFile: CreationFile
    let onAction: () -> Void
    
    init(currentFile: CreationFile, onAction: @escaping () -> Void) {
        self.currentFile  = currentFile
        self.onAction     = onAction
    }
    
    var body: some View {
        
        Button(action: onAction) {
            VStack(spacing: 10) {
                Image(nsImage: IconCache.shared.icon(fileType: self.currentFile.lang))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 58)
                
                Text(self.currentFile.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        
    }
}
