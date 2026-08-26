import Charts
import SwiftUI

enum HomeMetricKind: String, Identifiable {
    case avoided, saved, cravings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .avoided: return "少抽"
        case .saved: return "节省"
        case .cravings: return "今日烟瘾"
        }
    }

    var symbol: String {
        switch self {
        case .avoided: return "lungs.fill"
        case .saved: return "yensign.circle.fill"
        case .cravings: return "waveform.path.ecg"
        }
    }

    var tint: Color {
        switch self {
        case .avoided: return .green
        case .saved: return .blue
        case .cravings: return .orange
        }
    }

    var unit: String {
        switch self {
        case .avoided: return "根"
        case .saved: return "元"
        case .cravings: return "次"
        }
    }

    var chartTitle: String {
        switch self {
        case .avoided: return "今日少抽进度"
        case .saved: return "今日节省进度"
        case .cravings: return "今日烟瘾节奏"
        }
    }
}

private struct HomeMetricPoint: Identifiable {
    let hour: Int
    let value: Double
    let series: String
    var id: String { "\(series)-\(hour)" }
}

struct HomeMetricDetailView: View {
    let metric: HomeMetricKind
    let profile: QuitProfile
    let records: [CravingRecord]

    private let calendar = Calendar.current

    private var todayInterval: DateInterval {
        calendar.dateInterval(of: .day, for: .now)!
    }

    private var yesterdayInterval: DateInterval {
        let yesterday = calendar.date(byAdding: .day, value: -1, to: todayInterval.start)!
        return calendar.dateInterval(of: .day, for: yesterday)!
    }

    private var todayRecords: [CravingRecord] { records.filter { todayInterval.contains($0.createdAt) } }
    private var yesterdayRecords: [CravingRecord] { records.filter { yesterdayInterval.contains($0.createdAt) } }

    private var todayValue: Double { value(for: todayRecords) }
    private var yesterdayValue: Double { value(for: yesterdayRecords) }

    private var todayPoints: [HomeMetricPoint] {
        let currentHour = max(1, calendar.component(.hour, from: .now))
        return points(records: todayRecords, hours: 0...currentHour, series: "今天")
    }

    private var yesterdayPoints: [HomeMetricPoint] {
        points(records: yesterdayRecords, hours: 0...23, series: "昨天")
    }

    private var insight: String {
        switch metric {
        case .avoided:
            return todayValue == 0 ? "今天还没有忍住记录。下一次烟瘾来时，可以打开急救页给自己几分钟。" : "每成功忍住一次，按少抽 1 支计算；曲线显示今天累计的坚持。"
        case .saved:
            return todayValue == 0 ? "节省金额会随成功忍住的记录更新。" : "节省按你的每包价格和每包支数换算；这是一笔看得见的坚持。"
        case .cravings:
            return todayValue == 0 ? "今天还没有记录烟瘾。提前记录诱因和心情，能帮助找到高风险时段。" : "曲线上升的时段，就是今天需要更多准备与支持的时段。"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                summaryCard
                chartCard
                insightCard
                HStack(spacing: 12) {
                    comparisonCard(title: "今天", value: formatted(todayValue), tint: metric.tint)
                    comparisonCard(title: "昨天", value: formatted(yesterdayValue), tint: .secondary)
                }
            }
            .padding()
        }
        .background(LiquidGlassBackdrop())
        .navigationTitle(metric.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("当日数据", systemImage: metric.symbol)
                .font(.headline)
                .foregroundStyle(metric.tint)
            Text(formatted(todayValue))
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
            Text(comparisonText)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(yesterdayValue == 0 ? .secondary : metric.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: metric.tint.opacity(0.13), cornerRadius: 22)
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(metric.chartTitle)
                    .font(.headline)
                Spacer()
                HStack(spacing: 10) {
                    legend(title: "今天", color: metric.tint)
                    legend(title: "昨天", color: .gray)
                }
            }

            Chart {
                ForEach(yesterdayPoints) { point in
                    LineMark(
                        x: .value("小时", point.hour),
                        y: .value("数值", point.value)
                    )
                    .foregroundStyle(.gray.opacity(0.6))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 4]))
                    .interpolationMethod(.stepEnd)
                }
                ForEach(todayPoints) { point in
                    LineMark(
                        x: .value("小时", point.hour),
                        y: .value("数值", point.value)
                    )
                    .foregroundStyle(metric.tint)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.stepEnd)
                }
            }
            .chartXAxis {
                AxisMarks(values: [0, 6, 12, 18, 24]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hour = value.as(Int.self) { Text(hour == 24 ? "24" : String(format: "%02d", hour)) }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXScale(domain: 0...24)
            .frame(height: 220)
        }
        .padding()
        .liquidGlassCard(tint: .white.opacity(0.08), cornerRadius: 22)
    }

    private var insightCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("怎么看这张图", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
            Text(insight)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: metric.tint.opacity(0.08), cornerRadius: 18)
    }

    private func comparisonCard(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline).foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: tint.opacity(0.08), cornerRadius: 16)
    }

    private func legend(title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var comparisonText: String {
        guard yesterdayValue > 0 else { return "昨天没有可对比的记录" }
        let delta = todayValue - yesterdayValue
        let sign = delta > 0 ? "+" : ""
        return "较昨日 \(sign)\(formattedNumber(delta)) \(metric.unit)"
    }

    private func formatted(_ value: Double) -> String {
        switch metric {
        case .saved:
            return value.formatted(.currency(code: "CNY"))
        case .avoided, .cravings:
            return "\(Int(value)) \(metric.unit)"
        }
    }

    private func formattedNumber(_ value: Double) -> String {
        metric == .saved ? value.formatted(.number.precision(.fractionLength(2))) : String(Int(value))
    }

    private func value(for source: [CravingRecord]) -> Double {
        switch metric {
        case .avoided:
            return Double(source.filter { !$0.didSmoke }.count)
        case .saved:
            let successes = source.filter { !$0.didSmoke }.count
            return Double(successes) / Double(max(profile.cigarettesPerPack, 1)) * profile.packPrice
        case .cravings:
            return Double(source.count)
        }
    }

    private func points(records: [CravingRecord], hours: ClosedRange<Int>, series: String) -> [HomeMetricPoint] {
        var result: [HomeMetricPoint] = []
        for hour in hours {
            let cumulative = records.filter { calendar.component(.hour, from: $0.createdAt) <= hour }
            result.append(HomeMetricPoint(hour: hour, value: value(for: cumulative), series: series))
        }
        return result
    }
}
