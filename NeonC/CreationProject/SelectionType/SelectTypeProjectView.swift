//
//  CreationProjectView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 11/08/25.
//

import SwiftUI

struct SelectTypeProjectView: View {
    @State private var selectedTabIndex: Int
    @ObservedObject var navigationState: NavigationState
    @State private var currentLanguage: LanguageProject?
    
    init(navigationState: NavigationState) {
        self.selectedTabIndex = 0
        self.navigationState = navigationState
        self._currentLanguage = State(initialValue: navigationState.navigationItem.currentLanguage)
    }
    
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
                    currentLanguage = navigationState.navigationItem.currentLanguage
                    navigationState.closeCreateProjectPanel()
                }
                .buttonStyle(.glass)
                
                Spacer()
                
                Button("Next") {
                    if let lang = currentLanguage {
                        navigationState.navigationItem.currentLanguage = lang
                        navigationState.navigationItem.navigationState = .CREATE_PROJECT
                    }
                }
                .disabled(currentLanguage == nil)
                .buttonStyle(.glassProminent)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func tabContent(for tab: TabCategoryItem, idx: Int) -> some View {
        if selectedTabIndex == idx {
            VStack(alignment: .leading, spacing: 15) {
                ForEach(tab.creationModalities, id: \.title) { currentModality in
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
