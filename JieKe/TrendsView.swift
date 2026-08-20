import Charts
import SwiftUI

struct TrendsView: View {
    private let samples = (0..<7).map { TrendSample(day: $0, cravings: 0) }

    var body: some View {
        List {
            Section("最近 7 天烟瘾") {
                Chart(samples) { item in
                    LineMark(
                        x: .value("天", item.day),
                        y: .value("次数", item.cravings)
                    )
                }
                .frame(height: 220)
            }
            Section("累计") {
                LabeledContent("节省", value: "¥0")
                LabeledContent("少抽", value: "0 根")
            }
        }
        .navigationTitle("趋势")
    }
}

private struct TrendSample: Identifiable {
    let day: Int
    let cravings: Int
    var id: Int { day }
}
