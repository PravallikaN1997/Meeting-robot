import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("reminderMinutes") var reminderMinutes: Int = 5
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("showTomorrowMeetings") var showTomorrow: Bool = true
    @StateObject private var launchManager = LaunchAtLoginManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .accessibilityAddTraits(.isHeader)

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                settingsRow(
                    icon: "bell.fill", iconColor: .orange,
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
                        .accessibilityLabel("Reminder time before meeting")
                        .accessibilityValue("\(reminderMinutes) minutes")
                    )
                )

                Divider().padding(.leading, 36)

                settingsRow(
                    icon: "moon.fill", iconColor: .purple,
                    title: "Dark mode",
                    control: AnyView(
                        Toggle("Dark mode", isOn: $isDarkMode)
                            .toggleStyle(.switch).scaleEffect(0.8).labelsHidden()
                            .accessibilityLabel("Dark mode")
                            .accessibilityValue(isDarkMode ? "on" : "off")
                    )
                )

                Divider().padding(.leading, 36)

                settingsRow(
                    icon: "calendar", iconColor: .blue,
                    title: "Show tomorrow's meetings",
                    control: AnyView(
                        Toggle("Show tomorrow", isOn: $showTomorrow)
                            .toggleStyle(.switch).scaleEffect(0.8).labelsHidden()
                            .accessibilityLabel("Show tomorrow's meetings")
                            .accessibilityValue(showTomorrow ? "on" : "off")
                    )
                )

                Divider().padding(.leading, 36)

                settingsRow(
                    icon: "power", iconColor: .green,
                    title: "Launch at login",
                    control: AnyView(
                        Toggle("Launch at login", isOn: Binding(
                            get: { launchManager.isEnabled },
                            set: { _ in launchManager.toggle() }
                        ))
                        .toggleStyle(.switch).scaleEffect(0.8).labelsHidden()
                        .accessibilityLabel("Launch at login")
                        .accessibilityValue(launchManager.isEnabled ? "on" : "off")
                        .accessibilityHint("Automatically starts Meetbot when you log in")
                    )
                )
            }
            .padding(.vertical, 4)

            Divider()

            HStack {
                Text("Meetbot v1.0")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .accessibilityLabel("Meetbot version 1.0")
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
                .accessibilityHidden(true)
            Text(title).font(.system(size: 12))
            Spacer()
            control
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
