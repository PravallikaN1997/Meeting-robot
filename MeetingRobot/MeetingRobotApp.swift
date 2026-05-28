import SwiftUI

@main
struct MeetingRobotApp: App {
    @StateObject private var calendarManager = CalendarManager.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        // Main window — only shown during onboarding
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
                .onAppear {
                    OverlayWindowController.shared
                        .startMonitoring(calendarManager: calendarManager)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        // Menu bar icon — always present after launch
        MenuBarExtra {
            MenuBarView()
                .environmentObject(calendarManager)
        } label: {
            Label("Meetbot", systemImage: "calendar.badge.clock")
        }
        .menuBarExtraStyle(.window)
    }
}
