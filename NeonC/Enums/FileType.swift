//
//  FileType.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 26/08/25.
//

enum FileType: String, Codable {
    case c
    case cpp
    case cmake
    case h
    case cu

    var fileExtension: String {
        switch self {
        case .c    : return "c"
        case .cpp  : return "cpp"
        case .cmake: return "txt"
        case .h    : return "h"
        case .cu   : return "cu"
        }
    }
}
