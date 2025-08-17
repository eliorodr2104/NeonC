//
//  RequirementRow.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

struct RequirementRow: View {
    
    let requierement: RequirementItem
    
    var body: some View {
        
        HStack(alignment: .center) {
            
            ZStack {
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(requierement.colorBgIcon.opacity(0.18))
                    .frame(width: 32, height: 32)
                
                Image(systemName: requierement.icon)
                    .frame(width: 24, height: 24)
                
            }
                        
            VStack(alignment: .leading) {
                
                Text(requierement.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(requierement.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
            }
            
        }
        
    }
}
