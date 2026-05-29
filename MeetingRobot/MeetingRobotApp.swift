import SwiftUI
import ServiceManagement

@main
struct MeetingRobotApp: App {
    @StateObject private var calendarManager = CalendarManager.shared
    @StateObject private var launchManager = LaunchAtLoginManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSetInitialAppearance") private var hasSetInitialAppearance = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
                .onAppear {
                    setInitialAppearanceIfNeeded()
                    OverlayWindowController.shared
                        .startMonitoring(calendarManager: calendarManager)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(calendarManager)
        } label: {
            Label("Meetbot", systemImage: "calendar.badge.clock")
        }
        .menuBarExtraStyle(.window)
    }

    private func setInitialAppearanceIfNeeded() {
        guard !hasSetInitialAppearance else { return }
        let systemIsDark = NSApp.effectiveAppearance.bestMatch(
            from: [.darkAqua, .aqua]
        ) == .darkAqua
        isDarkMode = systemIsDark
        hasSetInitialAppearance = true
    }
}
