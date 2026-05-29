import SwiftUI

// MARK: - Hex initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Colors

extension Color {
    static let mrBackground    = Color(hex: "0A0A0A")
    static let mrSurface       = Color(hex: "141414")
    static let mrAccent        = Color(hex: "00D4FF")
    static let mrTextPrimary   = Color.white
    static let mrTextSecondary = Color(hex: "888888")
    static let mrBorder        = Color(hex: "222222")
}

// MARK: - Fonts

extension Font {
    static let mrHeading    = Font.system(.title, design: .rounded).weight(.semibold)
    static let mrSubheading = Font.system(.title3, design: .rounded).weight(.light)
    static let mrButton     = Font.system(.callout, design: .monospaced).weight(.semibold)
    static let mrBody       = Font.system(.body, design: .rounded)
    static let mrBubble     = Font.system(.caption, design: .monospaced, weight: .regular)
}

// MARK: - Spacing

enum MRSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 40
    static let xxl: CGFloat = 64
}

// MARK: - Corner radius

enum MRRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 20
    static let pill: CGFloat = 999
}
