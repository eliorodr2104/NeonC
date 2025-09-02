//
//  ProjectListView.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import SwiftUI

struct ProjectListView: View {
    let projects: [RecentProject]
    let onSelect: (RecentProject) -> Void
    let onDelete: (RecentProject) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(projects, id: \.id) { project in
                    ProjectRow(
                        project : project,
                        onSelect: { onSelect(project) },
                        onDelete: { onDelete(project) },
                        lang    : project.language
                    )
                    .id(project.id)
                    
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
