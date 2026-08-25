import Charts
import SwiftData
import SwiftUI

struct TrendsView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt) private var records: [CravingRecord]
    @State private var selectedPeriod: SummaryPeriod = .day

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
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
                    if periodRecords.isEmpty {
                        ContentUnavailableView("暂无记录", systemImage: "chart.bar", description: Text("记录一次烟瘾后，这里会显示趋势。"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else {
                        ScreenTimeTrendCard(
                            period: selectedPeriod,
                            points: periodTrendPoints,
                            successCount: periodSummary.successCount,
                            relapseCount: periodSummary.relapseCount
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                }

                Section("\(selectedPeriod.rawValue)复吸记录") {
                    LabeledContent("复吸", value: "\(periodSummary.relapseCount) 次")
                    LabeledContent("抽了", value: "\(periodSummary.smokedCigarettes) 根")
                    LabeledContent("浪费", value: periodSummary.spentMoney.formatted(.currency(code: "CNY")))
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

                Section("戒烟日历") {
                    QuitCalendarView(records: records)
                }

                Section("常见诱因") {
                    if triggerSummary.isEmpty { Text("多记录几次后，这里会显示你的高风险诱因。").foregroundStyle(.secondary) }
                    ForEach(triggerSummary) { item in LabeledContent(item.name, value: "\(item.count) 次") }
                }

                Section("有效应对方式") {
                    if copingSummary.isEmpty {
                        Text("在烟瘾急救中选择喝水、走动或转移注意后，这里会告诉你哪种方式最有帮助。")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(copingSummary) { item in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack {
                                Label(item.name, systemImage: item.symbol)
                                Spacer()
                                Text("\(item.successCount) / \(item.totalCount) 次忍住")
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: item.successRate)
                                .tint(.green)
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("趋势")
        }
    }

    private var periodRecords: [CravingRecord] {
        records.filter { selectedPeriod.contains($0.createdAt) }
    }

    private var periodTrendPoints: [TrendPoint] {
        let calendar = Calendar.current
        let now = Date.now

        switch selectedPeriod {
        case .day:
            let grouped = Dictionary(grouping: periodRecords, by: { calendar.component(.hour, from: $0.createdAt) })
            return (0..<24).compactMap { hour in
                guard calendar.date(bySettingHour: hour, minute: 0, second: 0, of: now) != nil else { return nil }
                return TrendPoint(label: String(format: "%02d", hour), records: grouped[hour] ?? [])
            }
        case .week:
            guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
            let grouped = Dictionary(grouping: periodRecords, by: { calendar.startOfDay(for: $0.createdAt) })
            return (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: week.start) else { return nil }
                return TrendPoint(label: date.formatted(.dateTime.month().day()), records: grouped[calendar.startOfDay(for: date)] ?? [])
            }
        case .month:
            guard let dayRange = calendar.range(of: .day, in: .month, for: now) else { return [] }
            let grouped = Dictionary(grouping: periodRecords, by: { calendar.component(.day, from: $0.createdAt) })
            return dayRange.compactMap { day in
                guard let date = calendar.date(bySetting: .day, value: day, of: now) else { return nil }
                return TrendPoint(label: "\(day)", records: grouped[day] ?? [])
            }
        case .year:
            let year = calendar.component(.year, from: now)
            let grouped = Dictionary(grouping: periodRecords, by: { calendar.component(.month, from: $0.createdAt) })
            return (1...12).compactMap { month in
                var components = calendar.dateComponents([.year], from: now)
                components.month = month
                components.day = 1
                guard calendar.date(from: components) != nil else { return nil }
                let matches = grouped[month]?.filter { calendar.component(.year, from: $0.createdAt) == year } ?? []
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

    private var copingSummary: [CopingSummary] {
        let grouped = Dictionary(grouping: records.filter { !$0.copingMethod.isEmpty }, by: \.copingMethod)
        return grouped
            .map { CopingSummary(name: $0.key, records: $0.value) }
            .sorted { lhs, rhs in
                lhs.successRate == rhs.successRate ? lhs.totalCount > rhs.totalCount : lhs.successRate > rhs.successRate
            }
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

private struct CopingSummary: Identifiable {
    let name: String
    let totalCount: Int
    let successCount: Int
    var id: String { name }
    var successRate: Double { totalCount == 0 ? 0 : Double(successCount) / Double(totalCount) }
    var symbol: String {
        switch name {
        case "喝水": "drop.fill"
        case "走动": "figure.walk"
        default: "sparkles"
        }
    }

    init(name: String, records: [CravingRecord]) {
        self.name = name
        totalCount = records.count
        successCount = records.filter { !$0.didSmoke }.count
    }
}

private struct ScreenTimeTrendCard: View {
    let period: SummaryPeriod
    let points: [TrendPoint]
    let successCount: Int
    let relapseCount: Int

    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("\(period.rawValue)烟瘾")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Chart(points) { item in
                    BarMark(x: .value("时间", item.label), y: .value("次数", item.successCount))
                        .foregroundStyle(Color.green.gradient)
                    BarMark(x: .value("时间", item.label), y: .value("次数", item.relapseCount))
                        .foregroundStyle(Color.red.gradient)
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        AxisValueLabel { if let count = value.as(Int.self) { Text("\(count)") } }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: visibleLabels) { AxisValueLabel() }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 190)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 24) {
                Text("\(successCount + relapseCount) 次")
                    .font(.system(.title, design: .rounded, weight: .bold))
                TrendLegend(color: .green, title: "忍住", value: "\(successCount) 次")
                TrendLegend(color: .red, title: "复吸", value: "\(relapseCount) 次")
            }
            .frame(width: 92, alignment: .leading)
            .padding(.bottom, 4)
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var visibleLabels: [String] {
        let preferredIndices: [Int]
        switch period {
        case .day: preferredIndices = [0, 6, 12, 18, 23]
        case .week: preferredIndices = [0, 2, 4, 6]
        case .month: preferredIndices = [0, 7, 14, 21, points.count - 1]
        case .year: preferredIndices = [0, 3, 6, 9, 11]
        }
        return preferredIndices.compactMap { points.indices.contains($0) ? points[$0].label : nil }
    }
}

private struct TrendLegend: View {
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: "circle.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
}
