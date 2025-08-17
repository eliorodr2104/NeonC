//
//  CreationProjectView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct SelectTypeProjectView: View {
    @State private var selectedTabIndex: Int = 0
    @ObservedObject var navigationState: NavigationState
    @State private var currentLanguage: LanguageProject?
    
    var body: some View {
        let tabCategoriesProjects = ProjectTemplatesStore.shared.templates
        
        VStack(alignment: .leading) {
            Text("Choose a template for you new project")
                .font(.title2)
                .foregroundStyle(.primary)
                .bold()
            
            TabView(selection: $selectedTabIndex) {
                ForEach(Array(tabCategoriesProjects.enumerated()), id: \.offset) { pair in
                    tabContent(for: pair.element, idx: pair.offset)
                        .tabItem {
                            Label(pair.element.title, systemImage: pair.element.icon)
                        }
                        .tag(pair.offset)
                }
            }
            .tabViewStyle(.sidebarAdaptable)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    // Restore selection to initial value and close
                    currentLanguage = navigationState.navigationItem.currentLanguageProject
                    // Only request close, let parent dismiss
                    navigationState.closeCreateProjectPanel()
                }
                .buttonStyle(.glass)
                
                Spacer()
                
                Button("Next") {
                    if let lang = currentLanguage {
                        navigationState.navigationItem.currentLanguageProject = lang
                        navigationState.navigationItem.secondaryNavigation = .CREATE_PROJECT
                    }
                }
                .disabled(currentLanguage == nil)
                .buttonStyle(.glassProminent)
            }
        }
        .padding()
        .onAppear {
            if currentLanguage == nil {
                currentLanguage = navigationState.navigationItem.currentLanguageProject
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: TabCategoryItem, idx: Int) -> some View {
        if selectedTabIndex == idx {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(tab.creationModalities, id: \.id) { currentModality in
                    ModalityBoxView(
                        currentModality: currentModality,
                        isSelected: currentModality.languageProject == currentLanguage
                    ) {
                        currentLanguage = currentModality.languageProject
                    }
                }
            }
            .padding()
        } else {
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    SelectTypeProjectView(navigationState: NavigationState())
}
