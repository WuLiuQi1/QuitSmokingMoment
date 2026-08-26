import SwiftUI

struct QuitCalendarView: View {
    let records: [CravingRecord]
    let snapshot: QuitCalendarSnapshot
    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    @State private var selectedDay: CalendarDaySelection?

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        VStack(spacing: 10) {
            HStack {
                Text(snapshot.monthStart, format: .dateTime.year().month())
                    .font(.headline)
                Spacer()
                Label("忍住", systemImage: "circle.fill").foregroundStyle(.green)
                Label("复吸", systemImage: "circle.fill").foregroundStyle(.red)
            }
            .font(.caption)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { Text($0).font(.caption2).foregroundStyle(.secondary) }
                ForEach(0..<snapshot.leadingDays, id: \.self) { _ in Color.clear.frame(height: 32) }
                ForEach(snapshot.days) { day in
                    CalendarDay(day: day) {
                        selectedDay = CalendarDaySelection(date: day.date)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .sheet(item: $selectedDay) { selection in
            NavigationStack {
                CalendarDayDetail(date: selection.date, records: records.filter { calendar.isDate($0.createdAt, inSameDayAs: selection.date) })
            }
        }
    }
}

private struct CalendarDay: View {
    let day: QuitCalendarDay
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text("\(day.day)").font(.caption)
                HStack(spacing: 3) {
                    if day.hasSuccess { Circle().fill(.green).frame(width: 5, height: 5) }
                    if day.hasRelapse { Circle().fill(.red).frame(width: 5, height: 5) }
                }
                .frame(height: 5)
            }
            .frame(maxWidth: .infinity, minHeight: 32)
            .background(Calendar.current.isDateInToday(day.date) ? Color.accentColor.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct QuitCalendarRecordState: Sendable {
    let createdAt: Date
    let didSmoke: Bool
}

struct QuitCalendarSnapshot {
    let monthStart: Date
    let leadingDays: Int
    let days: [QuitCalendarDay]

    init(records: [QuitCalendarRecordState], now: Date = .now, calendar: Calendar = .current) {
        let month = calendar.dateInterval(of: .month, for: now)!
        monthStart = month.start
        leadingDays = calendar.component(.weekday, from: month.start) - 1
        let recordsByDay = Dictionary(grouping: records.filter { $0.createdAt >= month.start && $0.createdAt < month.end }) {
            calendar.component(.day, from: $0.createdAt)
        }
        let range = calendar.range(of: .day, in: .month, for: now)!
        days = range.compactMap { value in
            guard let date = calendar.date(bySetting: .day, value: value, of: month.start) else { return nil }
            let dayRecords = recordsByDay[value] ?? []
            return QuitCalendarDay(
                day: value,
                date: date,
                hasSuccess: dayRecords.contains { !$0.didSmoke },
                hasRelapse: dayRecords.contains { $0.didSmoke }
            )
        }
    }
}

struct QuitCalendarDay: Identifiable {
    let day: Int
    let date: Date
    let hasSuccess: Bool
    let hasRelapse: Bool
    var id: Int { day }
}

private struct CalendarDaySelection: Identifiable {
    let date: Date
    var id: Date { date }
}

private struct CalendarDayDetail: View {
    let date: Date
    let records: [CravingRecord]

    var body: some View {
        List {
            Section {
                LabeledContent("烟瘾记录", value: "\(records.count) 次")
                LabeledContent("成功忍住", value: "\(records.filter { !$0.didSmoke }.count) 次")
                LabeledContent("复吸", value: "\(records.filter(\.didSmoke).count) 次")
            }
            if records.isEmpty {
                ContentUnavailableView("这天没有记录", systemImage: "calendar")
            } else {
                Section("当天详情") {
                    ForEach(records) { record in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(record.didSmoke ? "复吸 \(record.cigaretteCount) 根" : "成功忍住")
                                    .foregroundStyle(record.didSmoke ? .red : .green)
                                Spacer()
                                Text(record.createdAt, format: .dateTime.hour().minute())
                                    .foregroundStyle(.secondary)
                            }
                            Text("强度 \(record.intensity) · \(record.mood) · \(record.trigger)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if !record.copingMethod.isEmpty { Label(record.copingMethod, systemImage: "hand.thumbsup") .font(.caption) }
                            if !record.note.isEmpty { Text(record.note).font(.caption) }
                        }
                        .padding(.vertical, 3)
                    }
                }
            }
        }
        .navigationTitle(date.formatted(.dateTime.month().day()))
        .navigationBarTitleDisplayMode(.inline)
    }
}
