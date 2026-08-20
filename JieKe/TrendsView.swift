import Charts
import SwiftData
import SwiftUI

struct TrendsView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt) private var records: [CravingRecord]
    var body: some View {
        List {
            if let profile = profiles.first {
                let metrics = QuitMetrics(profile: profile, records: records, now: .now)
                Section("最近 7 天烟瘾") {
                    Chart(lastSevenDays) { item in
                        BarMark(
                            x: .value("日期", item.date, unit: .day),
                            y: .value("次数", item.count)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                        .chartYAxis { AxisMarks(position: .leading) }.frame(height: 220)
                }
                Section("累计") { LabeledContent("节省", value: metrics.savedMoney.formatted(.currency(code: "CNY"))); LabeledContent("少抽", value: "\(metrics.avoidedCigarettes) 根"); LabeledContent("已记录烟瘾", value: "\(records.count) 次") }
                Section("常见诱因") {
                    if triggerSummary.isEmpty { Text("多记录几次后，这里会显示你的高风险诱因。").foregroundStyle(.secondary) }
                    ForEach(triggerSummary, id: \.name) { item in LabeledContent(item.name, value: "\(item.count) 次") }
                }
            }
        }.navigationTitle("趋势")
    }
    private var lastSevenDays: [TrendPoint] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { offset in guard let date = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: .now)) else { return nil }; return TrendPoint(date: date, count: records.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count) }
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
    let date: Date
    let count: Int
    var id: Date { date }
}

private struct TriggerSummary: Identifiable {
    let name: String
    let count: Int
    var id: String { name }
}
