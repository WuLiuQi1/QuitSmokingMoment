import SwiftData
import SwiftUI

@main
struct QuitSmokingMomentApp: App {
    var body: some Scene {
        WindowGroup {
            PrivacyProtectedView { RootView() }
        }
        .modelContainer(for: [QuitProfile.self, CravingRecord.self])
    }
}
