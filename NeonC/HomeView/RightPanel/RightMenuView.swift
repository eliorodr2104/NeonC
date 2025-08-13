//
//  RigthMenuView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//



import SwiftUI

struct RightMenuView: View {
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var recentProjectsStore: RecentProjectsStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderPanelView()
            
            if recentProjectsStore.projects.isEmpty {
                Spacer()
                
            } else {
                ProjectListView(
                    projects: recentProjectsStore.projects,
                    onSelect: handleProjectSelection,
                    onDelete: handleProjectDeletion
                )
            }
        }
        .background(backgroundView)
        .frame(minWidth: 350, idealWidth: 350, maxWidth: 550, maxHeight: .infinity, alignment: .topLeading)
    }
    
    // MARK: - Subviews ottimizzate
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 26)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
    }
    
    // MARK: - Action handlers ottimizzati
    
    private func handleProjectSelection(_ project: RecentProject) {
       
        navigationState.navigationItem.selectedProjectPath = project.path
        navigationState.navigationItem.selectedProjectName = project.name
        navigationState.navigationItem.navigationState = .OPEN_PROJECT
    }
    
    private func handleProjectDeletion(_ project: RecentProject) {
        guard let index = recentProjectsStore.projects.firstIndex(where: { $0.id == project.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            recentProjectsStore.removeProject(at: IndexSet(integer: index))
        }
    }
}
