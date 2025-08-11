//
//  CreationProjectView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct CreationProjectView: View {
    static let defaultTabs: [TabCategoryItem] = [
        TabCategoryItem(
            id: "executable",
            title: "Executable",
            icon: "apple.terminal.on.rectangle",
            creationModalities: [
                CreationModalityItem(
                    id: "c-exe",
                    title: "C Executable",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new executable project using C language"
                ),
                
                CreationModalityItem(
                    id: "cpp-exe",
                    title: "C++ Executable",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new executable project using C++ language"
                ),
                
                CreationModalityItem(
                    id: "cuda-exe",
                    title: "CUDA Executable",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new executable project using CUDA language"
                )
            ]
            
        ),
        
        TabCategoryItem(
            id: "library",
            title: "Library",
            icon: "building.columns",
            creationModalities: [
                CreationModalityItem(
                    id: "c-lib",
                    title: "C Library",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new library using C language"
                ),
                
                CreationModalityItem(
                    id: "cpp-lib",
                    title: "C++ Library",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new library using C++ language"
                ),
                
                CreationModalityItem(
                    id: "cuda-lib",
                    title: "CUDA Library",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new library using CUDA language"
                )
            ]
        ),
        
        TabCategoryItem(
            id: "gui",
            title: "GUI",
            icon: "inset.filled.rectangle.and.person.filled",
            creationModalities: [
                CreationModalityItem(
                    id: "qt-exe",
                    title: "Qt Console Executable",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new program Qt using C/C++ language"
                ),
                
                CreationModalityItem(
                    id: "qt-widg-exe",
                    title: "Qt Widget Executable",
                    icon: "apple.terminal.on.rectangle",
                    description: "Create a new Qt widget using C/C++ language"
                )
            ]
        )
    ]
    
    @ObservedObject var templatesStore = ProjectTemplatesStore.shared

    var tabCategoriesProjects: [TabCategoryItem] { templatesStore.templates }
    
    @State private var selectedTabIndex: Int = 0
    @ObservedObject var navigationState: NavigationState
    
    var body: some View {
        
        VStack(
            alignment: .leading
        ) {
            
            Text("Choose a template for you new project")
                .font(.title2)
                .foregroundStyle(.primary)
            
            TabView(selection: $selectedTabIndex) {
                ForEach(Array(tabCategoriesProjects.enumerated()), id: \.offset) { idx, currentTab in
                    // Qui rendiamo il contenuto SOLO se questa tab è attiva
                    Group {
                        if selectedTabIndex == idx {
                            // contenuto "pesante" costruito solo quando questa tab è effettivamente selezionata
                            VStack(alignment: .leading, spacing: 15) {
                            ForEach(currentTab.creationModalities, id: \.title) { currentModality in
                                ModalityBoxView(currentModality: currentModality)
                            }
                        }
                        .padding()
                        } else {
                            // placeholder leggero: evita che SwiftUI costruisca tutto il subtree
                            Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .tabItem {
                        Label(currentTab.title, systemImage: currentTab.icon)
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            
            Spacer()
            
            HStack {
                
                Button("Cancel") {
                    navigationState.closeCreateProjectPanel()
                }
                .buttonStyle(.glass)
                
                Spacer()
                
                Button("Next") {
                    
                }
                .buttonStyle(.glassProminent)
                
            }
            
        }
        .padding()
        
    }
}

#Preview {
    CreationProjectView(navigationState: NavigationState())
}
