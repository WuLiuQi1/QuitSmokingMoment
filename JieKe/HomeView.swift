import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt, order: .reverse) private var records: [CravingRecord]
    @State private var showsRescue = false
    @State private var showsSettings = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            if let profile = profiles.first {
                let metrics = QuitMetrics(profile: profile, records: records, now: timeline.date)
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("已戒烟").foregroundStyle(.secondary)
                            Text(metrics.elapsedText).font(.system(.largeTitle, design: .rounded, weight: .bold)).contentTransition(.numericText())
                            Text(profile.quitDate, format: .dateTime.year().month().day().hour().minute()).font(.caption).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity).padding(.vertical, 28).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
                        HStack(spacing: 10) {
                            MetricCard(title: "少抽", value: "\(metrics.avoidedCigarettesText) 根", symbol: "lungs.fill")
                            MetricCard(title: "节省", value: metrics.savedMoney.formatted(.currency(code: "CNY")), symbol: "yensign.circle.fill")
                            MetricCard(title: "今日烟瘾", value: "\(metrics.todayCravings) 次", symbol: "waveform.path.ecg")
                        }
                        Text("每成功忍住 1 次，计为少抽 1 支；已成功度过 \(metrics.successfullyHandledCravings) 次烟瘾。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button { showsRescue = true } label: { Label("我现在想抽烟", systemImage: "shield.lefthalf.filled").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 10) }
                            .buttonStyle(.borderedProminent).controlSize(.large)
                        VStack(alignment: .leading, spacing: 10) {
                            Label("健康里程碑", systemImage: metrics.milestone.symbol).font(.headline)
                            Text(metrics.milestone.title).font(.title3.bold())
                            Text(metrics.milestone.detail).foregroundStyle(.secondary)
                        }.frame(maxWidth: .infinity, alignment: .leading).padding().background(.quaternary, in: RoundedRectangle(cornerRadius: 18))
                    }.padding()
                }
            }
        }
        .navigationTitle("戒刻")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("设置", systemImage: "gearshape") { showsSettings = true } } }
        .sheet(isPresented: $showsRescue) { NavigationStack { CravingRescueView() } }
        .sheet(isPresented: $showsSettings) { NavigationStack { SettingsView() } }
    }
}

private struct MetricCard: View {
    let title: String; let value: String; let symbol: String
    var body: some View {
        VStack(spacing: 8) { Image(systemName: symbol).foregroundStyle(.tint); Text(value).font(.headline).lineLimit(1).minimumScaleFactor(0.75); Text(title).font(.caption).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity).padding(.vertical).background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}
