import Foundation
import SwiftUI

struct QuitMetrics {
    let profile: QuitProfile
    let records: [CravingRecord]
    let now: Date

    var elapsedText: String {
        guard now >= profile.quitDate else { return "即将开始" }
        let elapsed = Calendar.current.dateComponents([.day, .hour, .minute], from: profile.quitDate, to: now)
        let days = elapsed.day ?? 0
        let hours = elapsed.hour ?? 0
        let minutes = elapsed.minute ?? 0
        if days > 0 { return "\(days) 天 \(hours) 小时" }
        if hours > 0 { return "\(hours) 小时 \(minutes) 分钟" }
        return "\(max(0, minutes)) 分钟"
    }

    var smokedCigarettes: Int { records.filter(\.didSmoke).reduce(0) { $0 + $1.cigaretteCount } }
    var avoidedCigarettes: Int { successfullyHandledCravings }
    var avoidedCigarettesText: String { "\(avoidedCigarettes)" }
    var savedMoney: Double { guard profile.cigarettesPerPack > 0 else { return 0 }; return Double(avoidedCigarettes) / Double(profile.cigarettesPerPack) * profile.packPrice }
    var todayCravings: Int { records.filter { Calendar.current.isDateInToday($0.createdAt) }.count }
    var successfullyHandledCravings: Int { records.filter { !$0.didSmoke }.count }

    var relapseFreeStart: Date {
        max(profile.quitDate, records.filter(\.didSmoke).map(\.createdAt).max() ?? profile.quitDate)
    }

    var relapseFreeText: String {
        guard now >= relapseFreeStart else { return "刚刚开始" }
        let elapsed = Calendar.current.dateComponents([.day, .hour], from: relapseFreeStart, to: now)
        let days = elapsed.day ?? 0
        let hours = elapsed.hour ?? 0
        return days > 0 ? "\(days) 天 \(hours) 小时" : "\(hours) 小时"
    }

    var healthMilestones: [HealthMilestone] {
        HealthMilestone.all.map { milestone in
            milestone.updatingStatus(elapsed: max(0, now.timeIntervalSince(profile.quitDate)))
        }
    }

    var milestone: HealthMilestone {
        healthMilestones.last(where: { $0.isCompleted }) ?? healthMilestones[0]
    }

    var nextHealthMilestone: HealthMilestone? {
        healthMilestones.first(where: { !$0.isCompleted })
    }

    var achievements: [QuitAchievement] {
        let quitDays = max(0, now.timeIntervalSince(profile.quitDate) / 86_400)
        let relapseFreeDays = max(0, now.timeIntervalSince(relapseFreeStart) / 86_400)
        return [
            QuitAchievement(title: "迈出第一步", detail: "成功度过 1 次烟瘾", symbol: "figure.walk", tint: .blue, isUnlocked: successfullyHandledCravings >= 1),
            QuitAchievement(title: "首日坚持", detail: "已戒烟满 24 小时", symbol: "sun.max.fill", tint: .orange, isUnlocked: quitDays >= 1),
            QuitAchievement(title: "十次少吸", detail: "成功度过 10 次烟瘾", symbol: "hands.clap.fill", tint: .green, isUnlocked: successfullyHandledCravings >= 10),
            QuitAchievement(title: "省下第一笔", detail: "累计节省满 ¥10", symbol: "yensign.circle.fill", tint: .mint, isUnlocked: savedMoney >= 10),
            QuitAchievement(title: "一周新生活", detail: "已戒烟满 7 天", symbol: "calendar.badge.checkmark", tint: .purple, isUnlocked: quitDays >= 7),
            QuitAchievement(title: "重新站稳", detail: "连续无复吸满 3 天", symbol: "shield.checkered", tint: .teal, isUnlocked: relapseFreeDays >= 3)
        ]
    }

    var nextAchievement: QuitAchievement? {
        achievements.first(where: { !$0.isUnlocked })
    }
}

struct HealthMilestone: Identifiable {
    let id: String
    let title: String
    let benefit: String
    let symbol: String
    let tint: Color
    let targetInterval: TimeInterval
    var isCompleted = false
    var remainingInterval: TimeInterval = 0

    static let all: [HealthMilestone] = [
        HealthMilestone(id: "start", title: "开始恢复", benefit: "停止吸烟后，身体开始排出一氧化碳。", symbol: "lungs.fill", tint: .mint, targetInterval: 0),
        HealthMilestone(id: "eightHours", title: "8 小时", benefit: "血液中一氧化碳水平下降，氧气运输逐步改善。", symbol: "drop.fill", tint: .blue, targetInterval: 8 * 3_600),
        HealthMilestone(id: "oneDay", title: "24 小时", benefit: "心脏病发作风险开始下降，身体继续清除烟草残留。", symbol: "heart.fill", tint: .red, targetInterval: 24 * 3_600),
        HealthMilestone(id: "twoDays", title: "48 小时", benefit: "嗅觉和味觉可能开始恢复，神经末梢逐步再生。", symbol: "nose.fill", tint: .purple, targetInterval: 48 * 3_600),
        HealthMilestone(id: "threeDays", title: "72 小时", benefit: "支气管开始放松，呼吸可能感觉更轻松。", symbol: "wind", tint: .teal, targetInterval: 72 * 3_600),
        HealthMilestone(id: "oneWeek", title: "1 周", benefit: "循环和肺部功能持续改善，日常活动可能更轻松。", symbol: "figure.walk", tint: .green, targetInterval: 7 * 86_400),
        HealthMilestone(id: "oneMonth", title: "1 个月", benefit: "咳嗽和气短可能减少，肺部纤毛逐步恢复清洁功能。", symbol: "lungs.fill", tint: .cyan, targetInterval: 30 * 86_400),
        HealthMilestone(id: "threeMonths", title: "3 个月", benefit: "血液循环和肺功能可继续提升，运动耐受度通常更好。", symbol: "figure.run", tint: .orange, targetInterval: 90 * 86_400),
        HealthMilestone(id: "oneYear", title: "1 年", benefit: "冠心病风险可显著下降；长期收益仍会继续累积。", symbol: "heart.circle.fill", tint: .pink, targetInterval: 365 * 86_400)
    ]

    func updatingStatus(elapsed: TimeInterval) -> HealthMilestone {
        var copy = self
        copy.isCompleted = elapsed >= targetInterval
        copy.remainingInterval = max(0, targetInterval - elapsed)
        return copy
    }

    var remainingText: String {
        let hours = Int(ceil(remainingInterval / 3_600))
        if hours <= 0 { return "已完成" }
        if hours < 24 { return "还需 \(hours) 小时" }
        let days = Int(ceil(Double(hours) / 24))
        return "还需 \(days) 天"
    }
}

struct QuitAchievement: Identifiable {
    let title: String
    let detail: String
    let symbol: String
    let tint: Color
    let isUnlocked: Bool
    var id: String { title }
}

enum RecordChoices {
    static let defaultMoods = ["平静", "焦虑", "烦躁", "疲惫", "开心", "压力大"]
    static let defaultTriggers = ["饭后", "工作压力", "社交", "喝酒", "开车", "无聊", "看到别人抽烟", "其他"]

    static var moods: [String] { defaultMoods + RecordChoiceStore.customMoods }
    static var triggers: [String] { defaultTriggers + RecordChoiceStore.customTriggers }
}

enum RecordChoiceStore {
    private static let moodsKey = "customRecordMoods"
    private static let triggersKey = "customRecordTriggers"

    static var customMoods: [String] { values(for: moodsKey) }
    static var customTriggers: [String] { values(for: triggersKey) }

    static func addMood(_ value: String) { add(value, key: moodsKey, excluding: RecordChoices.defaultMoods) }
    static func addTrigger(_ value: String) { add(value, key: triggersKey, excluding: RecordChoices.defaultTriggers) }
    static func removeMood(_ value: String) { remove(value, key: moodsKey) }
    static func removeTrigger(_ value: String) { remove(value, key: triggersKey) }

    private static func values(for key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    private static func add(_ rawValue: String, key: String, excluding defaults: [String]) {
        let value = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, !defaults.contains(value), !values(for: key).contains(value) else { return }
        UserDefaults.standard.set(values(for: key) + [value], forKey: key)
    }

    private static func remove(_ value: String, key: String) {
        UserDefaults.standard.set(values(for: key).filter { $0 != value }, forKey: key)
    }
}

enum SummaryPeriod: String, CaseIterable, Identifiable {
    case day = "当日"
    case week = "本周"
    case month = "本月"
    case year = "本年"
    var id: String { rawValue }

    func contains(_ date: Date, now: Date = .now, calendar: Calendar = .current) -> Bool {
        let component: Calendar.Component
        switch self {
        case .day: component = .day
        case .week: component = .weekOfYear
        case .month: component = .month
        case .year: component = .year
        }
        guard let interval = calendar.dateInterval(of: component, for: now) else { return false }
        return interval.contains(date)
    }
}

struct PeriodSummary {
    let records: [CravingRecord]
    let profile: QuitProfile

    var successCount: Int { records.filter { !$0.didSmoke }.count }
    var relapseCount: Int { records.filter(\.didSmoke).count }
    var smokedCigarettes: Int { records.filter(\.didSmoke).reduce(0) { $0 + $1.cigaretteCount } }
    var spentMoney: Double { guard profile.cigarettesPerPack > 0 else { return 0 }; return Double(smokedCigarettes) / Double(profile.cigarettesPerPack) * profile.packPrice }
    var tarMilligrams: Double { Double(smokedCigarettes) * profile.tarMilligramsPerCigarette }
}

struct RiskInsight {
    let hour: Int
    let count: Int
    let trigger: String

    static func from(records: [CravingRecord], calendar: Calendar = .current) -> RiskInsight? {
        let riskRecords = records.filter { $0.didSmoke || $0.intensity >= 7 }
        guard riskRecords.count >= 2 else { return nil }
        let grouped = Dictionary(grouping: riskRecords, by: { calendar.component(.hour, from: $0.createdAt) })
        guard let mostLikely = grouped.max(by: { $0.value.count < $1.value.count }) else { return nil }
        let triggers = Dictionary(grouping: mostLikely.value.filter { !$0.trigger.isEmpty }, by: \.trigger)
        let trigger = triggers.max(by: { $0.value.count < $1.value.count })?.key ?? "这个时段"
        return RiskInsight(hour: mostLikely.key, count: mostLikely.value.count, trigger: trigger)
    }

    var timeText: String { String(format: "%02d:00", hour) }
}
