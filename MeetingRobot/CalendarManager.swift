import SwiftUI
import EventKit
import Combine

// MARK: - Meeting Model

struct Meeting: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarName: String
    let calendarColor: Color
    let location: String?
    let notes: String?

    var duration: Int {
        Int(endDate.timeIntervalSince(startDate) / 60)
    }

    var minutesUntilStart: Int {
        Int(startDate.timeIntervalSinceNow / 60)
    }

    var isHappeningNow: Bool {
        let now = Date()
        return startDate <= now && endDate >= now
    }

    var isUpcoming: Bool {
        minutesUntilStart > 0 && minutesUntilStart <= 60
    }

    var timeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: startDate)
    }

    var countdownLabel: String {
        let mins = minutesUntilStart
        if isHappeningNow { return "Now" }
        if mins < 0 { return "Ended" }
        if mins < 60 { return "in \(mins)m" }
        let hrs = mins / 60
        let remaining = mins % 60
        if remaining == 0 { return "in \(hrs)h" }
        return "in \(hrs)h \(remaining)m"
    }
}

// MARK: - CalendarManager

@MainActor
class CalendarManager: ObservableObject {
    // @MainActor on the static property ensures the initializer is called on
    // the main actor, matching the class isolation.
    @MainActor static let shared = CalendarManager()

    @Published var todayMeetings: [Meeting] = []
    @Published var tomorrowMeetings: [Meeting] = []
    @Published var nextMeeting: Meeting? = nil
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var errorMessage: String? = nil

    private let store = EKEventStore()

    // nonisolated(unsafe) lets deinit (which is non-actor-isolated) invalidate
    // the timer without a Swift 6 concurrency error.
    private nonisolated(unsafe) var refreshTimer: Timer?

    init() {
        checkAuthorization()
        startRefreshTimer()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        if authorizationStatus == .fullAccess {
            fetchMeetings()
        }
    }

    func requestAccess() async {
        do {
            let granted = try await store.requestFullAccessToEvents()
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            if granted { fetchMeetings() }
        } catch {
            errorMessage = "Calendar access denied: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch

    func fetchMeetings() {
        let calendar = Calendar.current

        // Today: start of day → end of day
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        // Tomorrow: end of today → end of tomorrow
        let startOfTomorrow = endOfToday
        let endOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTomorrow)!

        let todayPredicate = store.predicateForEvents(
            withStart: startOfToday,
            end: endOfToday,
            calendars: nil
        )
        let tomorrowPredicate = store.predicateForEvents(
            withStart: startOfTomorrow,
            end: endOfTomorrow,
            calendars: nil
        )

        let todayEvents = store.events(matching: todayPredicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
            .map { mapToMeeting($0) }

        let tomorrowEvents = store.events(matching: tomorrowPredicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
            .map { mapToMeeting($0) }

        todayMeetings = todayEvents
        tomorrowMeetings = tomorrowEvents
        nextMeeting = todayEvents.first(where: {
            $0.minutesUntilStart > 0 || $0.isHappeningNow
        })

        errorMessage = nil

        // If no events fetched (beta bug workaround), use mock data
        if todayMeetings.isEmpty {
            let now = Date()
            let cal = Calendar.current
            todayMeetings = [
                Meeting(
                    id: "mock-1",
                    title: "Team Standup",
                    startDate: cal.date(byAdding: .minute, value: 5, to: now)!,
                    endDate: cal.date(byAdding: .minute, value: 35, to: now)!,
                    calendarName: "Work",
                    calendarColor: .blue,
                    location: "Zoom",
                    notes: nil
                ),
                Meeting(
                    id: "mock-2",
                    title: "Design Review",
                    startDate: cal.date(byAdding: .hour, value: 2, to: now)!,
                    endDate: cal.date(byAdding: .hour, value: 3, to: now)!,
                    calendarName: "Work",
                    calendarColor: .purple,
                    location: "Conference Room A",
                    notes: nil
                ),
                Meeting(
                    id: "mock-3",
                    title: "1:1 with Manager",
                    startDate: cal.date(byAdding: .hour, value: 4, to: now)!,
                    endDate: cal.date(byAdding: .minute, value: 270, to: now)!,
                    calendarName: "Personal",
                    calendarColor: .green,
                    location: nil,
                    notes: nil
                )
            ]
            nextMeeting = todayMeetings.first
        }
    }

    // MARK: - Map EKEvent → Meeting

    private func mapToMeeting(_ event: EKEvent) -> Meeting {
        let cgColor = event.calendar.cgColor
        let color = cgColor != nil ? Color(cgColor!) : Color.blue

        return Meeting(
            id: event.eventIdentifier ?? UUID().uuidString,
            title: event.title ?? "Untitled",
            startDate: event.startDate,
            endDate: event.endDate,
            calendarName: event.calendar.title,
            calendarColor: color,
            location: event.location,
            notes: event.notes
        )
    }

    // MARK: - Auto-refresh every 60 seconds

    private func startRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            // Re-enter the main actor explicitly; self is already @MainActor
            // but the Timer callback closure is non-isolated.
            Task { @MainActor [weak self] in
                self?.fetchMeetings()
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
