import ActivityKit
import SwiftUI
import WidgetKit

private struct QuitWidgetEntry: TimelineEntry {
    let date: Date
    let quitDate: Date
    let avoided: Int
    let saved: Double
}

private struct QuitWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuitWidgetEntry { entry() }
    func getSnapshot(in context: Context, completion: @escaping (QuitWidgetEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<QuitWidgetEntry>) -> Void) {
        let current = entry()
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        completion(Timeline(entries: [current], policy: .after(next)))
    }

    private func entry() -> QuitWidgetEntry {
        let defaults = UserDefaults(suiteName: "group.com.quitsmokingmoment.app")
        return QuitWidgetEntry(date: .now, quitDate: defaults?.object(forKey: "widgetQuitDate") as? Date ?? .now, avoided: defaults?.integer(forKey: "widgetAvoidedCigarettes") ?? 0, saved: defaults?.double(forKey: "widgetSavedMoney") ?? 0)
    }
}

struct QuitSmokingMomentWidget: Widget {
    let kind = "QuitSmokingMomentWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuitWidgetProvider()) { entry in
            QuitWidgetContent(entry: entry)
        }
        .configurationDisplayName("戒烟进度")
        .description("显示戒烟时长、少抽和节省金额。")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct QuitWidgetContent: View {
    let entry: QuitWidgetEntry
    @Environment(\.widgetFamily) private var family
    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                ZStack { AccessoryWidgetBackground(); Image(systemName: "lungs.fill").font(.title2); Text(entry.quitDate, style: .timer).font(.caption2).offset(y: 16) }
            case .accessoryRectangular:
                VStack(alignment: .leading) { Text("已戒烟").font(.caption); Text(entry.quitDate, style: .timer).font(.headline); Text("少抽 \(entry.avoided) 根").font(.caption2) }
            case .accessoryInline:
                Text("戒刻：已戒烟 \(entry.quitDate, style: .timer)，少抽 \(entry.avoided) 根")
            default:
                VStack(alignment: .leading, spacing: 8) {
                    Label("戒刻", systemImage: "lungs.fill").font(.headline).foregroundStyle(.mint)
                    Text(entry.quitDate, style: .timer).font(.system(.title2, design: .rounded, weight: .bold)).lineLimit(1).minimumScaleFactor(0.7)
                    HStack { Label("少抽 \(entry.avoided) 根", systemImage: "checkmark.circle.fill"); Spacer(); Text(entry.saved, format: .currency(code: "CNY")) }.font(.caption).foregroundStyle(.secondary)
                    Link(destination: URL(string: "jieke://rescue")!) { Label("烟瘾急救", systemImage: "shield.lefthalf.filled").font(.caption.weight(.semibold)) }
                }
                .containerBackground(.fill.tertiary, for: .widget)
            }
        }
    }
}

struct QuitSmokingMomentLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: QuitSmokingActivityAttributes.self) { context in
            HStack {
                Image(systemName: "lungs.fill").foregroundStyle(.mint)
                VStack(alignment: .leading) {
                    Text("已戒烟").font(.caption).foregroundStyle(.secondary)
                    Text(context.attributes.quitDate, style: .timer).font(.headline)
                }
                Spacer()
                Text("少抽 \(context.state.avoidedCigarettes) 根").font(.caption.weight(.semibold))
            }
            .padding(.horizontal)
            .activityBackgroundTint(Color.mint.opacity(0.18))
            .activitySystemActionForegroundColor(.mint)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Image(systemName: "lungs.fill").foregroundStyle(.mint) }
                DynamicIslandExpandedRegion(.trailing) { Text("少抽 \(context.state.avoidedCigarettes) 根").font(.caption) }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack { Text("已戒烟"); Text(context.attributes.quitDate, style: .timer); Spacer(); Text(context.state.savedMoney, format: .currency(code: "CNY")) }
                }
            } compactLeading: {
                Image(systemName: "lungs.fill").foregroundStyle(.mint)
            } compactTrailing: {
                Text(context.attributes.quitDate, style: .timer).monospacedDigit()
            } minimal: {
                Image(systemName: "lungs.fill").foregroundStyle(.mint)
            }
        }
    }
}

@main
struct QuitSmokingMomentWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuitSmokingMomentWidget()
        QuitSmokingMomentLiveActivity()
    }
}
