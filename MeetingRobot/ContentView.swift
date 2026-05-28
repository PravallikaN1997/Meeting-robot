import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                DashboardView()
                    .environmentObject(calendarManager)
            } else {
                OnboardingView(
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .frame(width: 600, height: 540)
            }
        }
        .onAppear {
            // TEMP: force onboarding for testing
            hasCompletedOnboarding = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarManager.shared)
}
