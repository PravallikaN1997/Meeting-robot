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
    @MainActor static let shared = CalendarManager()

    @Published var todayMeetings: [Meeting] = []
    @Published var tomorrowMeetings: [Meeting] = []
    @Published var nextMeeting: Meeting?
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let store = EKEventStore()
    private nonisolated(unsafe) var refreshTimer: Timer?

    init() {
        Task {
            await requestAccess()
        }
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
        isLoading = true
        do {
            let granted = try await store.requestFullAccessToEvents()
            authorizationStatus = EKEventStore.authorizationStatus(for: .event)
            if granted {
                fetchMeetings()
            } else {
                errorMessage = "Calendar access was denied. Please enable it in System Settings → Privacy → Calendars."
                isLoading = false
            }
        } catch {
            errorMessage = "Calendar access error: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Fetch

    func fetchMeetings() {
        isLoading = true
        errorMessage = nil

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
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

        isLoading = false
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
            Task { @MainActor [weak self] in
                self?.fetchMeetings()
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
