//
//  CompileProfile.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 14/08/25.
//

struct CompileProfile: Hashable, Codable {
    let compilerCPath: String
    let compilerCName: String
    let compilerCppPath: String
    let compilerCppName: String
    let cmakePath: String
    let cmakeName: String
    let ninjaPath: String
    let ninjaName: String
    let makePath: String
    let makeName: String

    init(
        compilerCPath: String = "",
        compilerCName: String = "",
        compilerCppPath: String = "",
        compilerCppName: String = "",
        cmakePath: String = "",
        cmakeName: String = "",
        ninjaPath: String = "",
        ninjaName: String = "",
        makePath: String = "", 
        makeName: String = ""
    ) {
        self.compilerCPath = compilerCPath
        self.compilerCName = compilerCName
        self.compilerCppPath = compilerCppPath
        self.compilerCppName = compilerCppName
        self.cmakePath = cmakePath
        self.cmakeName = cmakeName
        self.ninjaPath = ninjaPath
        self.ninjaName = ninjaName
        self.makePath = makePath
        self.makeName = makeName
    }
}
