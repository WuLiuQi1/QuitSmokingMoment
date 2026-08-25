import Foundation
import UserNotifications

@MainActor
enum NotificationManager {
    static let reminderIdentifier = "daily-quit-reminder"
    static let riskReminderIdentifier = "high-risk-reminder"

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleDailyReminder(at date: Date) async {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let content = UNMutableNotificationContent()
        content.title = "给自己一个赞"
        content.body = "今天也在为更轻松的呼吸而坚持。"
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        try? await center.add(request)
    }

    static func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    static func scheduleRiskReminder(for insight: RiskInsight) async {
        let content = UNMutableNotificationContent()
        content.title = "提前为自己准备一下"
        content.body = "你在 (insight.timeText) 前后较容易想抽烟（常见诱因：(insight.trigger)）。先喝水、走动 2 分钟。"
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: insight.hour, minute: 0), repeats: true)
        let request = UNNotificationRequest(identifier: riskReminderIdentifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [riskReminderIdentifier])
        try? await center.add(request)
    }

    static func cancelRiskReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [riskReminderIdentifier])
    }
}
