import SwiftUI

struct QuitCalendarView: View {
    let records: [CravingRecord]
    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        let month = calendar.dateInterval(of: .month, for: .now)!
        let days = calendar.range(of: .day, in: .month, for: .now)!
        let leadingDays = calendar.component(.weekday, from: month.start) - 1
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        let dayStatuses = Dictionary(grouping: records.filter { month.contains($0.createdAt) }, by: { calendar.component(.day, from: $0.createdAt) })

        VStack(spacing: 10) {
            HStack {
                Text(month.start, format: .dateTime.year().month())
                    .font(.headline)
                Spacer()
                Label("忍住", systemImage: "circle.fill").foregroundStyle(.green)
                Label("复吸", systemImage: "circle.fill").foregroundStyle(.red)
            }
            .font(.caption)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdays, id: \.self) { Text($0).font(.caption2).foregroundStyle(.secondary) }
                ForEach(0..<leadingDays, id: \.self) { _ in Color.clear.frame(height: 32) }
                ForEach(Array(days), id: \.self) { day in
                    CalendarDay(day: day, records: dayStatuses[day] ?? [])
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CalendarDay: View {
    let day: Int
    let records: [CravingRecord]

    var body: some View {
        VStack(spacing: 3) {
            Text("\(day)").font(.caption)
            HStack(spacing: 3) {
                if records.contains(where: { !$0.didSmoke }) { Circle().fill(.green).frame(width: 5, height: 5) }
                if records.contains(where: \.didSmoke) { Circle().fill(.red).frame(width: 5, height: 5) }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity, minHeight: 32)
        .background(Calendar.current.component(.day, from: .now) == day ? Color.accentColor.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 8))
    }
}
