import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        if hasCompletedOnboarding {
            DashboardView()
                .environmentObject(calendarManager)
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .frame(width: 600, height: 540)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarManager.shared)
}
