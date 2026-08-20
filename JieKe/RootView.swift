import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var profiles: [QuitProfile]
    var body: some View {
        Group {
            if profiles.isEmpty { OnboardingView() } else { MainTabView() }
        }
    }
}

private struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            Group {
                switch selection {
                case .home:
                    NavigationStack { HomeView() }
                case .records:
                    NavigationStack { RecordsView() }
                case .trends:
                    NavigationStack { TrendsView() }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            LiquidGlassDock(selection: $selection)
                .padding(.horizontal, 20)
                .padding(.bottom, 6)
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case home
    case records
    case trends

    var id: String { rawValue }
    var title: String {
        switch self {
        case .home: "首页"
        case .records: "记录"
        case .trends: "趋势"
        }
    }
    var symbol: String {
        switch self {
        case .home: "house.fill"
        case .records: "square.and.pencil"
        case .trends: "chart.xyaxis.line"
        }
    }
}

private struct LiquidGlassDock: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    Label(tab.title, systemImage: tab.symbol)
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(selection == tab ? Color.primary : Color.secondary)
                        .background { if selection == tab { Capsule().fill(.white.opacity(0.26)) } }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .liquidGlassCard(cornerRadius: 32)
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
    }
}
