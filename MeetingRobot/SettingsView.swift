import SwiftUI

struct SettingsView: View {
    @AppStorage("reminderMinutes") var reminderMinutes: Int = 5
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("showTomorrowMeetings") var showTomorrow: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                // Reminder timing
                settingsRow(
                    icon: "bell.fill",
                    iconColor: .orange,
                    title: "Remind me before",
                    control: AnyView(
                        Picker("", selection: $reminderMinutes) {
                            Text("5 mins").tag(5)
                            Text("10 mins").tag(10)
                            Text("15 mins").tag(15)
                            Text("30 mins").tag(30)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    )
                )

                Divider().padding(.leading, 36)

                // Dark mode
                settingsRow(
                    icon: "moon.fill",
                    iconColor: .purple,
                    title: "Dark mode",
                    control: AnyView(
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    )
                )

                Divider().padding(.leading, 36)

                // Show tomorrow
                settingsRow(
                    icon: "calendar",
                    iconColor: .blue,
                    title: "Show tomorrow's meetings",
                    control: AnyView(
                        Toggle("", isOn: $showTomorrow)
                            .toggleStyle(.switch)
                            .scaleEffect(0.8)
                    )
                )
            }
            .padding(.vertical, 4)

            Divider()

            // Version footer
            HStack {
                Text("Meetbot v1.0")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    private func settingsRow(icon: String, iconColor: Color,
                              title: String, control: AnyView) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(iconColor)
                .frame(width: 22, height: 22)
                .background(iconColor.opacity(0.12))
                .cornerRadius(5)

            Text(title)
                .font(.system(size: 12))

            Spacer()

            control
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
