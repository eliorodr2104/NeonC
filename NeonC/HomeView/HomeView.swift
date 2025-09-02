import SwiftUI

struct HomeView: View {
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var recentProjectsStore: RecentProjectsStore

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

    init(navigationState: NavigationState, recentProjectsStore: RecentProjectsStore) {
        self.navigationState = navigationState
        self.recentProjectsStore = recentProjectsStore
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
        HStack() {

            VStack(
                alignment: .leading, spacing: 25
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
                
                Spacer()
                
                Text("NeonC • \(appVersionString)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .padding(.leading, 12)
                
            }
            .padding()
            .frame(minWidth: 400, maxWidth: 400, maxHeight: .infinity, alignment: .leading)
            .glassEffect(in: .rect(cornerRadius: 26))
            
            Spacer()

            RightMenuView(navigationState: navigationState, recentProjectsStore: recentProjectsStore)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(15)
    }
}
