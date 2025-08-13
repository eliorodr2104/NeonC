import SwiftUI

struct HomeView: View {
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var recentProjectsStore: RecentProjectsStore
    @ObservedObject var lastStateApp: LastAppStateStore

    let defaultsMode: [ModeItem]
    
    private let icon = NSApplication.shared.applicationIconImage!
    @State private var glowColor: Color = .white
    @State private var computedAverage = false
    
    private var appVersionString: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    init(navigationState: NavigationState, recentProjectsStore: RecentProjectsStore, lastStateApp: LastAppStateStore) {
        self.navigationState = navigationState
        self.recentProjectsStore = recentProjectsStore
        self.lastStateApp = lastStateApp
        self.defaultsMode = [
            ModeItem(
                name: "Create A New Project",
                description: "Create a new C or C++ project",
                icon: "plus.app",
                function: { navigationState.showCreationProjectSheet() }
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
                
                Text("NeonC • \(appVersionString)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
            .padding(.leading, 25)
            .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            RightMenuView(navigationState: navigationState, recentProjectsStore: recentProjectsStore)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(10)
    }
}
