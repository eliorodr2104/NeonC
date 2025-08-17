//
//  RequirementItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

struct RequirementItem: Hashable, Identifiable {
    
    let id: Int8
    let title: String
    let description: String
    let icon: String
    let colorBgIcon: Color
    
    static func == (lhs: RequirementItem, rhs: RequirementItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.icon == rhs.icon
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(icon)
    }
}
