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
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.15, blue: 0.18), Color(red: 0.04, green: 0.29, blue: 0.33), Color(red: 0.10, green: 0.11, blue: 0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Circle()
                    .fill(.mint.opacity(0.72))
                    .frame(width: 380)
                    .blur(radius: 65)
                    .offset(x: -145, y: -270)
                Circle()
                    .fill(.cyan.opacity(0.58))
                    .frame(width: 320)
                    .blur(radius: 70)
                    .offset(x: 160, y: -20)
                Circle()
                    .fill(.indigo.opacity(0.62))
                    .frame(width: 430)
                    .blur(radius: 90)
                    .offset(x: -70, y: 390)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
