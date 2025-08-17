//
//  PathSelectorRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

struct PathSelectorRow: View {
    let title: String
    @Binding var path: String
    var isLoading: Bool
    var isWarning: Bool
    var onBrowse: (() -> Void)

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: $path)
                    .textFieldStyle(.roundedBorder)
                    .foregroundColor(isWarning ? .red : .primary)
                    .background(
                        isWarning ?
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.red.opacity(0.13)) : nil
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isWarning ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .disabled(isLoading)
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                }
                Button(action: {
                    onBrowse()
                }) {
                    Image(systemName: "folder")
                }
                .help("Select path")
                
            }
            if isWarning {
                Text("Not found. Select path.")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.leading, 3)
            }
        }
    }
}
