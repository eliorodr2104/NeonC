//
//  ProjectTemplateStore.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

import Foundation
internal import Combine

final class ProjectTemplatesStore: ObservableObject {
    static let shared = ProjectTemplatesStore()
    @Published private(set) var templates: [TabCategoryItem] = []
    
    private init() {
        loadTabTemplates()
    }
    
    private func loadTabTemplates() {
        guard let url = Bundle.main.url(forResource: "project_templates", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([TabCategoryItem].self, from: data)
            self.templates = decoded
        } catch {
            print("Error porsing JSON: \(error)")
        }
    }
}
