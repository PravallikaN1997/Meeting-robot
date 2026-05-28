import AppKit
import SwiftUI

class OverlayWindowController: NSObject {
    private var overlayWindow: NSWindow?
    // nonisolated(unsafe) so deinit can invalidate without actor isolation error
    private nonisolated(unsafe) var checkTimer: Timer?
    private var snoozedMeetingIds: Set<String> = []
    private var dismissedMeetingIds: Set<String> = []

    static let shared = OverlayWindowController()

    func startMonitoring(calendarManager: CalendarManager) {
        checkTimer?.invalidate()
        checkTimer = Timer.scheduledTimer(
            withTimeInterval: 30,
            repeats: true
        ) { [weak self] _ in
            // CalendarManager is @MainActor — dispatch to main thread
            DispatchQueue.main.async {
                self?.checkForUpcomingMeetings(
                    calendarManager: calendarManager
                )
            }
        }
        // Check immediately on start (called from onAppear — already on main)
        checkForUpcomingMeetings(calendarManager: calendarManager)
    }

    private func checkForUpcomingMeetings(
        calendarManager: CalendarManager
    ) {
        let reminderMinutes = UserDefaults.standard
            .integer(forKey: "reminderMinutes")
        let threshold = reminderMinutes == 0 ? 5 : reminderMinutes

        guard let meeting = calendarManager.todayMeetings.first(where: {
            let mins = $0.minutesUntilStart
            return mins > 0 && mins <= 60 &&
                   !snoozedMeetingIds.contains($0.id) &&
                   !dismissedMeetingIds.contains($0.id)
        }) else {
            return
        }

        DispatchQueue.main.async {
            self.showOverlay(for: meeting)
        }
    }

    func showOverlay(for meeting: Meeting) {
        // Don't show if already visible
        if overlayWindow?.isVisible == true { return }

        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.visibleFrame

        // Position: bottom-left corner
        let windowWidth: CGFloat = 320
        let windowHeight: CGFloat = 160
        let margin: CGFloat = 20

        let windowFrame = NSRect(
            x: screenFrame.minX + margin,
            y: screenFrame.minY + margin,
            width: windowWidth,
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
        window.hasShadow = true
        window.ignoresMouseEvents = false
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary
        ]

        let overlayView = OverlayView(
            meeting: meeting,
            onDismiss: { [weak self] in
                self?.dismissedMeetingIds.insert(meeting.id)
                self?.hideOverlay()
            }
        )

        window.contentView = NSHostingView(rootView: overlayView)

        // Slide in from bottom
        var startFrame = windowFrame
        startFrame.origin.y = -windowHeight
        window.setFrame(startFrame, display: false)
        window.orderFront(nil)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.4
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window.animator().setFrame(windowFrame, display: true)
        }

        self.overlayWindow = window
    }

    func hideOverlay() {
        guard let window = overlayWindow else { return }
        let endFrame = NSRect(
            x: window.frame.origin.x,
            y: -window.frame.height,
            width: window.frame.width,
            height: window.frame.height
        )
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            window.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            window.orderOut(nil)
            self.overlayWindow = nil
        })
    }

    deinit {
        checkTimer?.invalidate()
    }
}
