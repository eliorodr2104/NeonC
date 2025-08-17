//
//  WelcomeViewModel.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import AppKit
internal import Combine
import SwiftUI

// --- ViewModel singleton per app per questo scopo ---
final class WelcomeViewModel: ObservableObject {
    static let shared = WelcomeViewModel()
    
    @Published private(set) var glowColor: Color = .white
    private var didCompute = false
    
    private init() {
       
    }
    
    func computeGlowIfNeeded() {
        guard !didCompute else { return }
        didCompute = true
        
        guard let icon = NSApplication.shared.applicationIconImage else { return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            computeAverageColor(of: icon) { nsColor in
                DispatchQueue.main.async {
                    if let nsColor = nsColor {
                        self?.glowColor = Color(nsColor)
                        
                    } else {
                        self?.glowColor = .white
                        
                    }
                }
            }
        }
    }
}
