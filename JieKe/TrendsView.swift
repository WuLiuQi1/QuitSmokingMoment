import Charts
import SwiftData
import SwiftUI

struct TrendsView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt) private var records: [CravingRecord]
    @State private var selectedPeriod: SummaryPeriod = .day

    var body: some View {
        List {
            if let profile = profiles.first {
                let quitMetrics = QuitMetrics(profile: profile, records: records, now: .now)
                let periodSummary = PeriodSummary(records: periodRecords, profile: profile)

                Section("统计周期") {
                    Picker("统计周期", selection: $selectedPeriod) {
                        ForEach(SummaryPeriod.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }

                Section("\(selectedPeriod.rawValue)记录") {
                    Chart(periodTrendPoints) { item in
                        BarMark(x: .value("时间", item.label), y: .value("次数", item.successCount))
                            .foregroundStyle(Color.green)
                            .position(by: .value("结果", "忍住了"))
                        BarMark(x: .value("时间", item.label), y: .value("次数", item.relapseCount))
                            .foregroundStyle(Color.red)
                            .position(by: .value("结果", "没忍住"))
                    }
                    .chartYAxis { AxisMarks(position: .leading) }
                    .frame(height: 240)
                    HStack(spacing: 16) {
                        Label("绿色：忍住没抽", systemImage: "circle.fill").foregroundStyle(.green)
                        Label("红色：没忍住", systemImage: "circle.fill").foregroundStyle(.red)
                    }
                    .font(.caption)
                }

                Section("\(selectedPeriod.rawValue)复吸记录") {
                    LabeledContent("成功忍住", value: "\(periodSummary.successCount) 次")
                    LabeledContent("没忍住", value: "\(periodSummary.relapseCount) 次")
                    LabeledContent("抽了多少支", value: "\(periodSummary.smokedCigarettes) 根")
                    LabeledContent("浪费了多少钱", value: periodSummary.spentMoney.formatted(.currency(code: "CNY")))
                    LabeledContent("摄入焦油", value: "\(periodSummary.tarMilligrams.formatted(.number.precision(.fractionLength(1)))) mg")
                    Text("焦油量按设置的每支 \(profile.tarMilligramsPerCigarette.formatted(.number.precision(.fractionLength(1)))) mg 估算。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("戒烟累计") {
                    LabeledContent("节省", value: quitMetrics.savedMoney.formatted(.currency(code: "CNY")))
                    LabeledContent("少抽", value: "\(quitMetrics.avoidedCigarettesText) 根")
                    LabeledContent("已成功度过", value: "\(quitMetrics.successfullyHandledCravings) 次")
                    Text("每成功忍住 1 次，记为少抽 1 支，并按每包价格换算节省金额。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("常见诱因") {
                    if triggerSummary.isEmpty { Text("多记录几次后，这里会显示你的高风险诱因。").foregroundStyle(.secondary) }
                    ForEach(triggerSummary) { item in LabeledContent(item.name, value: "\(item.count) 次") }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("趋势")
    }

    private var periodRecords: [CravingRecord] {
        records.filter { selectedPeriod.contains($0.createdAt) }
    }

    private var periodTrendPoints: [TrendPoint] {
        let calendar = Calendar.current
        let now = Date.now

        switch selectedPeriod {
        case .day:
            return (0..<24).compactMap { hour in
                guard let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) else { return nil }
                let matches = periodRecords.filter { calendar.component(.hour, from: $0.createdAt) == hour }
                return TrendPoint(label: String(format: "%02d", hour), records: matches)
            }
        case .week:
            guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: week.start) else { return nil }
                let matches = records.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                return TrendPoint(label: date.formatted(.dateTime.month().day()), records: matches)
            }
        case .month:
            guard let dayRange = calendar.range(of: .day, in: .month, for: now) else { return [] }
            return dayRange.compactMap { day in
                guard let date = calendar.date(bySetting: .day, value: day, of: now) else { return nil }
                let matches = records.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
                return TrendPoint(label: "\(day)", records: matches)
            }
        case .year:
            return (1...12).compactMap { month in
                var components = calendar.dateComponents([.year], from: now)
                components.month = month
                components.day = 1
                guard let date = calendar.date(from: components) else { return nil }
                let matches = records.filter {
                    calendar.component(.year, from: $0.createdAt) == calendar.component(.year, from: now)
                    && calendar.component(.month, from: $0.createdAt) == month
                }
                return TrendPoint(label: "\(month)月", records: matches)
            }
        }
    }

    private var triggerSummary: [TriggerSummary] {
        let grouped = Dictionary(grouping: records.filter { !$0.trigger.isEmpty }, by: \.trigger)
        return grouped
            .map { TriggerSummary(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(5)
            .map { $0 }
    }
}

private struct TrendPoint: Identifiable {
    let label: String
    let successCount: Int
    let relapseCount: Int
    var id: String { label }

    init(label: String, records: [CravingRecord]) {
        self.label = label
        successCount = records.filter { !$0.didSmoke }.count
        relapseCount = records.filter(\.didSmoke).count
    }
}

private struct TriggerSummary: Identifiable {
    let name: String
    let count: Int
    var id: String { name }
}
