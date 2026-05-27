import SwiftUI

struct CyanPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mrButton)
            .foregroundColor(.mrBackground)
            .padding(.horizontal, MRSpacing.lg)
            .padding(.vertical, MRSpacing.sm + MRSpacing.xs)
            .background(Color.mrAccent)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct OutlinePillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.mrButton)
            .foregroundColor(.mrTextPrimary)
            .padding(.horizontal, MRSpacing.lg)
            .padding(.vertical, MRSpacing.sm + MRSpacing.xs)
            .background(Color.clear)
            .overlay(Capsule().stroke(Color.mrTextPrimary, lineWidth: 1.5))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
