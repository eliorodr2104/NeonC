import SwiftUI

struct HomeView: View {
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var recentProjectsStore: RecentProjectsStore
    
    @ObservedObject var lastStateApp: LastAppStateStore

    let defaultsMode: [ModeItem]
    
    private let icon = NSApplication.shared.applicationIconImage!
    @State private var glowColor: Color = .white
    @State private var computedAverage = false

    init(navigationState: NavigationState, recentProjectsStore: RecentProjectsStore, lastStateApp: LastAppStateStore) {
        self.navigationState = navigationState
        self.recentProjectsStore = recentProjectsStore
        self.lastStateApp = lastStateApp
        self.defaultsMode = [
            ModeItem(
                name: "Create A New Project",
                description: "Create a new C or C++ project",
                icon: "plus.app",
                function: { navigationState.showCreateProjectPanel() }
            ),
            ModeItem(
                name: "Open A Existing Project",
                description: "Browse your existing projects",
                icon: "folder",
                function: { navigationState.openProjectPanel() }
            ),
            ModeItem(
                name: "Clone Repository",
                description: "Clone from Git repositories",
                icon: "square.and.arrow.down.on.square",
                function: { }
            )
        ]
    }

    private var appVersionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        HStack(spacing: 30) {

            VStack(
                alignment: .leading, spacing: 35
            ) {
                HStack {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .shadow(color: glowColor.opacity(0.6), radius: 12, x: 0, y: 0)
                        .onAppear {
                            // calcola una volta solo
                            if !computedAverage {
                                computedAverage = true
                                computeAverageColor(of: icon) { nsColor in
                                    DispatchQueue.main.async {
                                        if let nsColor = nsColor {
                                            self.glowColor = Color(nsColor)
                                        } else {
                                            self.glowColor = .white
                                        }
                                    }
                                }
                            }
                        }
                    
                    VStack(alignment: .leading) {
                        Text("NeonC")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        
                        Text("Open Source C/C++ IDE")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(spacing: 15) {
                    ForEach(defaultsMode) { mode in
                        ModeButton(currentMode: mode)
                            .frame(maxWidth: 400)
                    }
                }
            }
            .padding(.leading, 25)
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            // Right: Recent projects custom panel
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text("Recent Projects")
                        .font(.title2.bold())
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 5)

                if recentProjectsStore.projects.isEmpty {
                    Spacer()
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(recentProjectsStore.projects, id: \.id) { project in
                                
                                VStack {
                                    ProjectRow(
                                        project: project,
                                        onSelect: {
                                            navigationState.selectedProjectPath = project.path
                                            navigationState.selectedProjectName = project.name
                                            navigationState.showOpenProjectAlert = true
                                        },
                                        onDelete: {
                                            if let idx = recentProjectsStore.projects.firstIndex(where: { $0.id == project.id }) {
                                                withAnimation {
                                                    recentProjectsStore.removeProject(at: IndexSet(integer: idx))
                                                }
                                            }
                                        }
                                    )
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    
                                }
                                
                            }
                        }
                        .padding()
                    }
                }

                Divider()
                    .padding(.vertical, 6)
                    .padding(.horizontal, 8)

                Text("NeonC • \(appVersionString)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
            )
            .frame(minWidth: 180, idealWidth: 350, maxWidth: 550, maxHeight: .infinity, alignment: .topLeading)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
}
