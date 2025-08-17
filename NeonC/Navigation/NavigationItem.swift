//
//  NavigationItem.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 12/08/25.
//

struct NavigationItem: Hashable {
    var principalNavigation: NavigationEnum = .HOME
    var secondaryNavigation: SecondaryNavigationEnum? = nil
    
    var currentLanguageProject: LanguageProject = .C_EXE
    
    var selectedProjectName: String = ""
    var selectedProjectPath: String = ""
}
