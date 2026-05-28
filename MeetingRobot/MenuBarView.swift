import SwiftUI
import EventKit

struct MenuBarView: View {
    @EnvironmentObject var calendarManager: CalendarManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("showTomorrowMeetings") var showTomorrow: Bool = true
    @AppStorage("reminderMinutes") var reminderMinutes: Int = 5
    @State private var showSettings: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Meetbot")
                        .font(.system(size: 13, weight: .semibold))
                    Text(todayLabel)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { calendarManager.fetchMeetings() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            // Next meeting highlight
            if let next = calendarManager.nextMeeting {
                nextMeetingBanner(next)
                Divider()
            }

            // Today's meetings list
            ScrollView {
                VStack(spacing: 0) {
                    if calendarManager.authorizationStatus != .fullAccess {
                        permissionRequest
                    } else if calendarManager.todayMeetings.isEmpty {
                        emptyState
                    } else {
                        ForEach(calendarManager.todayMeetings) { meeting in
                            MeetingRowView(meeting: meeting)
                            if meeting.id != calendarManager.todayMeetings.last?.id {
                                Divider().padding(.leading, 14)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 280)

            if showTomorrow && !calendarManager.tomorrowMeetings.isEmpty {
                Divider()
                HStack {
                    Text("Tomorrow")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 4)

                ForEach(calendarManager.tomorrowMeetings.prefix(3)) { meeting in
                    MeetingRowView(meeting: meeting)
                }

                if calendarManager.tomorrowMeetings.count > 3 {
                    Text("+\(calendarManager.tomorrowMeetings.count - 3) more")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.bottom, 8)
                }
            }

            Divider()

            // Footer
            HStack {
                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Spacer()
                Button("Settings") { showSettings.toggle() }
                    .buttonStyle(.plain)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .popover(isPresented: $showSettings) { SettingsView() }
        }
        .frame(width: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear { calendarManager.fetchMeetings() }
    }

    // MARK: - Next meeting banner

    private func nextMeetingBanner(_ meeting: Meeting) -> some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(meeting.calendarColor)
                .frame(width: 4, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(meeting.title)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                Text("\(meeting.timeLabel) · \(meeting.countdownLabel)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(meeting.countdownLabel)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(meeting.isHappeningNow ? .green : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(meeting.isHappeningNow ?
                              Color.green.opacity(0.15) :
                              Color.orange.opacity(0.15))
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - Permission request

    private var permissionRequest: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 28))
                .foregroundColor(.orange)
            Text("Calendar access needed")
                .font(.system(size: 13, weight: .medium))
            Text("Grant access to see your meetings")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Button("Grant Access") {
                Task { await calendarManager.requestAccess() }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            Text("No meetings today")
                .font(.system(size: 13, weight: .medium))
            Text("Enjoy your free day 🎉")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Helpers

    private var todayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }
}

// MARK: - Meeting Row

struct MeetingRowView: View {
    let meeting: Meeting

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(meeting.calendarColor)
                .frame(width: 4, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(meeting.title)
                    .font(.system(size: 12, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(meeting.isHappeningNow ? .primary :
                                    meeting.minutesUntilStart < 0 ? .secondary : .primary)
                HStack(spacing: 4) {
                    Text(meeting.timeLabel)
                    Text("·")
                    Text("\(meeting.duration)m")
                    if let loc = meeting.location, !loc.isEmpty {
                        Text("·")
                        Text(loc).lineLimit(1)
                    }
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }
            Spacer()
            Text(meeting.countdownLabel)
                .font(.system(size: 11))
                .foregroundColor(meeting.isHappeningNow ? .green :
                                meeting.minutesUntilStart < 0 ? .secondary : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(meeting.isHappeningNow ?
                    Color.green.opacity(0.05) : Color.clear)
    }
}
