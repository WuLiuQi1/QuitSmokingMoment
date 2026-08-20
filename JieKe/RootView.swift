import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("首页", systemImage: "house.fill") }

            NavigationStack { RecordsView() }
                .tabItem { Label("记录", systemImage: "square.and.pencil") }

            NavigationStack { TrendsView() }
                .tabItem { Label("趋势", systemImage: "chart.xyaxis.line") }
        }
    }
}

