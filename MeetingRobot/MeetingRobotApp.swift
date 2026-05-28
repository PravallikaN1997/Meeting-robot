import SwiftUI

@main
struct MeetingRobotApp: App {
    @StateObject private var calendarManager = CalendarManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
