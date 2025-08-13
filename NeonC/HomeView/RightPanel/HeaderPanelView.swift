//
//  HeaderPanelView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

struct HeaderPanelView: View {
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Recent Projects")
                .font(.title2)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .padding(.bottom, 10)
    }
}
