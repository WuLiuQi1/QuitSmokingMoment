import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt) private var records: [CravingRecord]
    @AppStorage("reduceMotionInApp") private var reduceMotionInApp = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var showsRescueFromWidget = false

    /// Changes whenever data shown by the widget changes. Keeping this at the
    /// root means records added or edited from any tab are shared immediately.
    private var widgetSyncToken: String {
        guard let profile = profiles.first else { return "no-profile" }
        let recordState = records.map {
            "\($0.createdAt.timeIntervalSinceReferenceDate)|\($0.didSmoke)|\($0.cigaretteCount)|\($0.intensity)"
        }.joined(separator: ",")
        return [
            String(profile.quitDate.timeIntervalSinceReferenceDate),
            String(profile.cigarettesPerDay),
            String(profile.packPrice),
            String(profile.cigarettesPerPack),
            recordState
        ].joined(separator: "#")
    }

    var body: some View {
        Group {
            if profiles.isEmpty { OnboardingView() } else { MainTabView() }
        }
        .transaction { transaction in
            if reduceMotionInApp { transaction.animation = nil }
        }
        .onOpenURL { url in
            if url.scheme == "jieke", url.host == "rescue" { showsRescueFromWidget = true }
        }
        .task(id: widgetSyncToken) {
            // Avoid publishing a half-written SwiftData edit while a user is typing.
            try? await Task.sleep(for: .milliseconds(250))
            guard !Task.isCancelled, let profile = profiles.first else { return }
            WidgetDataStore.publish(profile: profile, records: records)
            await LiveActivityManager.update(profile: profile, records: records)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, let profile = profiles.first else { return }
            WidgetDataStore.publish(profile: profile, records: records)
            Task { await LiveActivityManager.update(profile: profile, records: records) }
        }
        .sheet(isPresented: $showsRescueFromWidget) { NavigationStack { CravingRescueView() } }
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
