import ActivityKit
import Foundation

@MainActor
enum LiveActivityManager {
    static func start(profile: QuitProfile, records: [CravingRecord]) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let metrics = QuitMetrics(profile: profile, records: records, now: .now)
        let attributes = QuitSmokingActivityAttributes(quitDate: profile.quitDate)
        let state = QuitSmokingActivityAttributes.ContentState(avoidedCigarettes: metrics.avoidedCigarettes, savedMoney: metrics.savedMoney)
        let content = ActivityContent(state: state, staleDate: nil)
        _ = try? Activity.request(attributes: attributes, content: content, pushType: nil)
    }

    static func update(profile: QuitProfile, records: [CravingRecord]) async {
        let metrics = QuitMetrics(profile: profile, records: records, now: .now)
        let state = QuitSmokingActivityAttributes.ContentState(avoidedCigarettes: metrics.avoidedCigarettes, savedMoney: metrics.savedMoney)
        for activity in Activity<QuitSmokingActivityAttributes>.activities {
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
    }

    static func endAll() async {
        for activity in Activity<QuitSmokingActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
