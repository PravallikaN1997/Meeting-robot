import SwiftUI
import EventKit

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var showConfirmation = false

    var body: some View {
        ZStack {
            Color.mrBackground.ignoresSafeArea()

            if showConfirmation {
                ConfirmationView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showConfirmation)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            Spacer()

            RobotAnimationView()
                .frame(width: 220, height: 220)

            Spacer().frame(height: MRSpacing.xl)

            Text("Meeting Robot")
                .font(.mrHeading)
                .foregroundColor(.mrTextPrimary)

            Spacer().frame(height: MRSpacing.md)

            Text("I'll nudge you before every meeting.")
                .font(.mrSubheading)
                .foregroundColor(.mrTextSecondary)

            Spacer().frame(height: MRSpacing.xl + MRSpacing.md)

            HStack(spacing: MRSpacing.md) {
                Button("CONNECT APPLE CALENDAR") {
                    requestCalendarAccess()
                }
                .buttonStyle(CyanPillButtonStyle())

                Button("CONNECT GOOGLE CALENDAR") {
                    connectGoogleCalendar()
                }
                .buttonStyle(OutlinePillButtonStyle())
            }

            Spacer()
        }
        .padding(.horizontal, MRSpacing.xl + MRSpacing.sm)
    }

    private func requestCalendarAccess() {
        Task {
            let store = EKEventStore()
            do {
                let granted = try await store.requestFullAccessToEvents()
                if granted {
                    UserDefaults.standard.set("apple", forKey: "calendarProvider")
                    withAnimation(.easeInOut(duration: 0.4)) { showConfirmation = true }
                }
            } catch {
                // Permission denied or restricted — user stays on onboarding
            }
        }
    }

    private func connectGoogleCalendar() {
        // TODO: Implement full Google OAuth flow in a future phase
        UserDefaults.standard.set("google", forKey: "calendarProvider")
        withAnimation(.easeInOut(duration: 0.4)) { showConfirmation = true }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .frame(width: 600, height: 540)
}
