//
//  ClangVersions.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 13/08/25.
//

import Foundation

struct LanguagePack: Codable {
    struct RangeItem: Codable {
        let min: Int
        let max: Int? 
        let standards: [String]
    }
    let ranges: [RangeItem]
    let `default`: [String]
}
