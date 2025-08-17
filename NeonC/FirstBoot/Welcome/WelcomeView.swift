//
//  WelcomeView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

import SwiftUI

// --- Requisiti (statici, non ricreati ad ogni body) ---
private let kItemsRequirements: [RequirementItem] = [
    RequirementItem(
        id: 0,
        title: "C Compiler (GCC/Clang)",
        description: "For the C program compilation",
        icon: "terminal",
        colorBgIcon: Color.accentColor
    ),
    RequirementItem(
        id: 1,
        title: "C++ Compiler (G++/Clang++)",
        description: "For the C++ program compilation",
        icon: "terminal",
        colorBgIcon: Color.purple
    ),
    RequirementItem(
        id: 2,
        title: "Build tools",
        description: "Make, Cmake and Ninja",
        icon: "terminal",
        colorBgIcon: Color.yellow
    )
]

struct WelcomeView: View {
    
    @ObservedObject var navigationState: NavigationState
    @StateObject private var vm = WelcomeViewModel.shared
    
    private let icon = NSApplication.shared.applicationIconImage!
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            leftColumn
            Divider().padding(.trailing, 15)
            rightColumn
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            vm.computeGlowIfNeeded()
        }
    }
    
    // MARK: - Subviews split for readability and to avoid a huge body
    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top, spacing: 10) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .shadow(color: vm.glowColor.opacity(0.6), radius: 10, x: 0, y: 0)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome to NeonC")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                    
                    Text("Open Source Native MacOS C/C++ IDE")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 13)
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Text("This is your new professional development environment for C and C++.\nA modern IDE designed specifically for macOS.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Main Features:")
                        .font(.headline).bold()
                    
                    VStack(alignment: .leading, spacing: 7) {
                        Text("\t• Advanced code editor with syntax highlighting")
                        Text("\t• Integrated C/C++ project management")
                        Text("\t• Full support for modern build tools")
                        Text("\t• Native macOS interface with Liquid Glass design")
                        Text("\t• Compilation and direct execution from the IDE")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 10)
        }
        .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var rightColumn: some View {
        VStack(alignment: .leading, spacing: 25) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "gearshape")
                    .foregroundStyle(.placeholder)
                    .font(.title2)
                Text("System requirements")
                    .font(.title2)
            }
            
            VStack(spacing: 15) {
                ForEach(kItemsRequirements, id: \.id) { requirement in
                    RequirementRow(requierement: requirement)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .background(backgroundView)
            
            // Note
            VStack(alignment: .leading) {
                Text("Note:").bold()
                Text("If you haven't installed these tools, you can do so via Homebrew or Xcode Command Line Tools.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background)
            .overlay(RoundedRectangle(cornerRadius: 26)
                        .stroke(.placeholder.opacity(0.18), lineWidth: 1))
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Configure IDE") {
                    navigationState.navigationItem.principalNavigation = .SET_PATHS_APP
                }
                .buttonStyle(.glassProminent)
                
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 300, idealWidth: 300, maxWidth: 350, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 4)
    }
}

