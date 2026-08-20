import Foundation

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

    var milestone: (title: String, detail: String, symbol: String) {
        let hours = max(0, now.timeIntervalSince(profile.quitDate) / 3_600)
        switch hours {
        case 0..<8: return ("现在开始恢复", "身体正在清除一氧化碳。", "lungs.fill")
        case 8..<24: return ("血氧正在改善", "约 8 小时后，血液中的一氧化碳水平下降。", "drop.fill")
        case 24..<48: return ("恭喜坚持一天", "心率和血压已开始回落。", "heart.fill")
        case 48..<72: return ("呼吸会更轻松", "约 48 小时后，嗅觉和味觉开始恢复。", "nose.fill")
        default: return ("继续积累健康", "每一次拒绝，都是身体恢复的一步。", "figure.walk")
        }
    }
}

enum RecordChoices {
    static let moods = ["平静", "焦虑", "烦躁", "疲惫", "开心", "压力大"]
    static let triggers = ["饭后", "工作压力", "社交", "喝酒", "开车", "无聊", "看到别人抽烟", "其他"]
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
