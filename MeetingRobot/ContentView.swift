import SwiftUI

struct ContentView: View {
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some View {
        if hasCompletedOnboarding {
            ZStack {
                Color.mrBackground.ignoresSafeArea()
                Text("Dashboard — Phase 2")
                    .font(.mrSubheading)
                    .foregroundColor(.mrTextSecondary)
            }
            .frame(width: 600, height: 540)
        } else {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .frame(width: 600, height: 540)
        }
    }
}

#Preview {
    ContentView()
}
