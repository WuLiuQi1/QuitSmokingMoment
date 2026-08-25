import Foundation
import UserNotifications

@MainActor
enum NotificationManager {
    static let reminderIdentifier = "daily-quit-reminder"
    static let riskReminderIdentifier = "high-risk-reminder"
    static let healthMilestoneIdentifier = "health-milestone-reminder"
    static let reflectionReminderIdentifier = "daily-reflection-reminder"

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
        content.body = "你在 \(insight.timeText) 前后较容易想抽烟（常见诱因：\(insight.trigger)）。先喝水、走动 2 分钟。"
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

    static func scheduleAchievement(title: String, body: String, identifier: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false))
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func scheduleNextHealthMilestone(after quitDate: Date) async {
        let now = Date.now
        guard let milestone = HealthMilestone.all.dropFirst().first(where: {
            quitDate.addingTimeInterval($0.targetInterval) > now
        }) else { return }
        let fireDate = quitDate.addingTimeInterval(milestone.targetInterval)
        let content = UNMutableNotificationContent()
        content.title = "健康里程碑：\(milestone.title)"
        content.body = milestone.benefit
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let request = UNNotificationRequest(identifier: healthMilestoneIdentifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [healthMilestoneIdentifier])
        try? await center.add(request)
    }

    static func cancelHealthMilestoneReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [healthMilestoneIdentifier])
    }

    static func scheduleReflectionReminder(at date: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "花一分钟复盘今天"
        content.body = "记下今天的烟瘾、感受和最有用的应对方法。"
        content.sound = .default
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let request = UNNotificationRequest(identifier: reflectionReminderIdentifier, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true))
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reflectionReminderIdentifier])
        try? await center.add(request)
    }

    static func cancelReflectionReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reflectionReminderIdentifier])
    }
}
