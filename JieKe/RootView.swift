import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var profiles: [QuitProfile]
    @AppStorage("reduceMotionInApp") private var reduceMotionInApp = false
    var body: some View {
        Group {
            if profiles.isEmpty { OnboardingView() } else { MainTabView() }
        }
        .transaction { transaction in
            if reduceMotionInApp { transaction.animation = nil }
        }
    }
}

private struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            TabView(selection: $selection) {
                NavigationStack { HomeView() }
                    .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.symbol) }
                    .tag(AppTab.home)
                NavigationStack { RecordsView() }
                    .tabItem { Label(AppTab.records.title, systemImage: AppTab.records.symbol) }
                    .tag(AppTab.records)
                NavigationStack { TrendsView() }
                    .tabItem { Label(AppTab.trends.title, systemImage: AppTab.trends.symbol) }
                    .tag(AppTab.trends)
            }
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
