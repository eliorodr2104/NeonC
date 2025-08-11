//
//  ModeItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import Foundation

struct ModeItem: Identifiable {
    let id         : UUID   = UUID()
    let name       : String
    let description: String
    let icon       : String
    let function   : () -> Void
    
    
}
