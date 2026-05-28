import AppKit
import SwiftUI

class OverlayWindowController: NSObject {
    private var overlayWindow: NSWindow?
    private var checkTimer: Timer?
    private var dismissedMeetingIds: Set<String> = []

    static let shared = OverlayWindowController()

    func startMonitoring(calendarManager: CalendarManager) {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            self?.checkForUpcomingMeetings(
                calendarManager: calendarManager)
        }
        checkForUpcomingMeetings(calendarManager: calendarManager)
    }

    private func checkForUpcomingMeetings(
        calendarManager: CalendarManager
    ) {
        guard let meeting = calendarManager.todayMeetings
            .first(where: {
                let mins = $0.minutesUntilStart
                return mins > 0 && mins <= 60 &&
                       !dismissedMeetingIds.contains($0.id)
            }) else { return }

        DispatchQueue.main.async {
            self.showOverlay(for: meeting)
        }
    }

    func showOverlay(for meeting: Meeting) {
        if overlayWindow?.isVisible == true { return }

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.visibleFrame
        let windowHeight: CGFloat = 140

        let windowFrame = NSRect(
            x: screenFrame.minX,
            y: screenFrame.minY,
            width: screenFrame.width,
            height: windowHeight
        )

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = false
        window.ignoresMouseEvents = false
        window.collectionBehavior = [
            .canJoinAllSpaces, .fullScreenAuxiliary
        ]

        let overlayView = OverlayView(
            meeting: meeting,
            screenWidth: screenFrame.width,
            onFinished: { [weak self] in
                self?.dismissedMeetingIds.insert(meeting.id)
                window.orderOut(nil)
                self?.overlayWindow = nil
            }
        )

        window.contentView = NSHostingView(rootView: overlayView)
        window.orderFront(nil)
        self.overlayWindow = window
    }
}
