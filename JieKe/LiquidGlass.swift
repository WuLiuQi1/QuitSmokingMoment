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
        Color(uiColor: .systemGroupedBackground)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
