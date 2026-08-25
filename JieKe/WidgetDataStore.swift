import Foundation
import WidgetKit

enum WidgetDataStore {
    static let suiteName = "group.com.quitsmokingmoment.app"
    private static let quitDateKey = "widgetQuitDate"
    private static let avoidedKey = "widgetAvoidedCigarettes"
    private static let savedKey = "widgetSavedMoney"

    static func publish(profile: QuitProfile, records: [CravingRecord]) {
        let metrics = QuitMetrics(profile: profile, records: records, now: .now)
        let defaults = UserDefaults(suiteName: suiteName)
        defaults?.set(profile.quitDate, forKey: quitDateKey)
        defaults?.set(metrics.avoidedCigarettes, forKey: avoidedKey)
        defaults?.set(metrics.savedMoney, forKey: savedKey)
        WidgetCenter.shared.reloadAllTimelines()
    }

    static func currentValues() -> (quitDate: Date, avoided: Int, saved: Double) {
        let defaults = UserDefaults(suiteName: suiteName)
        return (
            defaults?.object(forKey: quitDateKey) as? Date ?? .now,
            defaults?.integer(forKey: avoidedKey) ?? 0,
            defaults?.double(forKey: savedKey) ?? 0
        )
    }
}
