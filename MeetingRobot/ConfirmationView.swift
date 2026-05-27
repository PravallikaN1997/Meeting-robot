import SwiftUI

struct ConfirmationView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            RobotAnimationView()
                .frame(width: 220, height: 220)

            Spacer().frame(height: MRSpacing.xl)

            Text("You're all set!")
                .font(.mrHeading)
                .foregroundColor(.mrTextPrimary)

            Spacer().frame(height: MRSpacing.md)

            Text("I'll remind you before every meeting.")
                .font(.mrSubheading)
                .foregroundColor(.mrTextSecondary)

            Spacer().frame(height: MRSpacing.xl + MRSpacing.md)

            Button("GET STARTED") {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                hasCompletedOnboarding = true
            }
            .buttonStyle(CyanPillButtonStyle())

            Spacer()
        }
        .padding(.horizontal, MRSpacing.xl + MRSpacing.sm)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.mrBackground)
    }
}

#Preview {
    ConfirmationView(hasCompletedOnboarding: .constant(false))
        .frame(width: 600, height: 540)
}
