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
    var body: some View {
        TabView {
            NavigationStack { HomeView() }.tabItem { Label("首页", systemImage: "house.fill") }
            NavigationStack { RecordsView() }.tabItem { Label("记录", systemImage: "square.and.pencil") }
            NavigationStack { TrendsView() }.tabItem { Label("趋势", systemImage: "chart.xyaxis.line") }
        }
    }
}

