import SwiftUI

extension View {
    @ViewBuilder
    func liquidGlassCard(tint: Color? = nil, cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, *) {
            let glass = tint.map { Glass.regular.tint($0) } ?? .regular
            self.glassEffect(glass, in: RoundedRectangle(cornerRadius: cornerRadius))
        } else {
            self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func liquidGlassProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

struct LiquidGlassBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.03, green: 0.16, blue: 0.18), Color(red: 0.03, green: 0.34, blue: 0.36), Color(red: 0.08, green: 0.12, blue: 0.30)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(.mint.opacity(0.85))
                .frame(width: 380)
                .blur(radius: 65)
                .offset(x: -145, y: -270)
            Circle()
                .fill(.cyan.opacity(0.68))
                .frame(width: 320)
                .blur(radius: 70)
                .offset(x: 160, y: -20)
            Circle()
                .fill(.indigo.opacity(0.72))
                .frame(width: 430)
                .blur(radius: 90)
                .offset(x: -70, y: 390)
        }
        .ignoresSafeArea()
    }
}
