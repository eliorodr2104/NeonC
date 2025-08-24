import SwiftUI
import AppKit

struct CodeEditorView: View {
    @Binding var text: String
    var pathFile: URL
    @ObservedObject var compilerProfile: CompilerProfileStore
    var projectRoot: URL
    @StateObject private var viewModel: CodeEditorViewModel
    var language: Language
    
    init(text: Binding<String>, compilerProfile: CompilerProfileStore, projectRoot: URL, pathFile: URL) {
        self._text = text
        self.compilerProfile = compilerProfile
        self.projectRoot = projectRoot
        self.pathFile = pathFile
        self._viewModel = StateObject(wrappedValue: CodeEditorViewModel(projectRoot: projectRoot, documentURI: pathFile))
        self.language = .c
    }

    var body: some View {
        VStack {
            TextViewWrapper(text: $text, viewModel: viewModel, language: language)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            viewModel.setupLSP(language: language)
        }
        .onChange(of: text) { oldText, newText in
            viewModel.textChanged(newText: newText)
        }
    }
}
