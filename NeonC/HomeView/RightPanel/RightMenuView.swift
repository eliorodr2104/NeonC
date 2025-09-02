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
        ProjectListView(
            projects: recentProjectsStore.projects,
            onSelect: handleProjectSelection,
            onDelete: handleProjectDeletion,
            
        )
        .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .trailing)
    }
        
    private func handleProjectSelection(_ project: RecentProject) {
       
        navigationState.navigationItem.selectedProjectPath = project.path
        navigationState.navigationItem.selectedProjectName = project.name
        
        navigationState.navigationItem.secondaryNavigation = .CONTROL_OPEN_PROJECT
    }
    
    private func handleProjectDeletion(_ project: RecentProject) {
        guard let index = recentProjectsStore.projects.firstIndex(where: { $0.id == project.id }) else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            recentProjectsStore.removeProject(at: IndexSet(integer: index))
        }
    }
}
