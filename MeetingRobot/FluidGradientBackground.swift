import SwiftUI

struct FluidGradientBackground: View {
    var body: some View {
        TimelineView(.animation) { tl in
            let t = Float(tl.date.timeIntervalSinceReferenceDate) * 0.18
            MeshGradient(
                width: 3, height: 3,
                points: animatedPoints(t: t),
                colors: palette,
                smoothsColors: true
            )
        }
        .ignoresSafeArea()
    }

    // Corner points are fixed; edge/interior points oscillate for a lava-lamp feel.
    private func animatedPoints(t: Float) -> [SIMD2<Float>] {
        [
            [0, 0],
            [0.5 + 0.18 * sin(t * 0.9),           0],
            [1, 0],

            [0,  0.5 + 0.14 * cos(t * 0.7 + 1.1)],
            [0.5 + 0.12 * cos(t * 1.1), 0.5 + 0.12 * sin(t * 0.8 + 0.4)],
            [1,  0.5 + 0.14 * sin(t * 0.6 + 2.0)],

            [0, 1],
            [0.5 + 0.16 * sin(t * 0.5 + 1.7),     1],
            [1, 1],
        ]
    }

    private let palette: [Color] = [
        Color(hex: "0D1B6E"), Color(hex: "1A4FBA"), Color(hex: "00D4FF"),
        Color(hex: "1A4FBA"), Color(hex: "00A896"), Color(hex: "0D1B6E"),
        Color(hex: "00A896"), Color(hex: "1A4FBA"), Color(hex: "0D1B6E"),
    ]
}
