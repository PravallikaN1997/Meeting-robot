import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var calendarManager: CalendarManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Today")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text(todayLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()

            if calendarManager.todayMeetings.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No meetings today")
                        .font(.system(size: 16, weight: .medium))
                    Text("Enjoy your free day 🎉")
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(calendarManager.todayMeetings) { meeting in
                            DashboardMeetingCard(meeting: meeting)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .frame(width: 600, height: 540)
        .onAppear { calendarManager.fetchMeetings() }
    }

    private var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

struct DashboardMeetingCard: View {
    let meeting: Meeting

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(meeting.calendarColor)
                .frame(width: 5, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(meeting.timeLabel)
                    Text("·")
                    Text("\(meeting.duration) min")
                    if let loc = meeting.location, !loc.isEmpty {
                        Text("·")
                        Text(loc).lineLimit(1)
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(meeting.countdownLabel)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(meeting.isHappeningNow ? .green :
                                    meeting.minutesUntilStart < 0 ? .secondary : .blue)
                Text(meeting.calendarName)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
        )
    }
}
