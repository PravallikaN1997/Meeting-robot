import ServiceManagement
import SwiftUI
import Combine

@MainActor
class LaunchAtLoginManager: ObservableObject {
    static let shared = LaunchAtLoginManager()
    @Published var isEnabled: Bool = false

    private init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func toggle() {
        isEnabled ? disable() : enable()
    }

    func enable() {
        do {
            try SMAppService.mainApp.register()
            isEnabled = true
        } catch {
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }

    func disable() {
        do {
            try SMAppService.mainApp.unregister()
            isEnabled = false
        } catch {
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }
}
