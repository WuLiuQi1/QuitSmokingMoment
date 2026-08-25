import SwiftUI

struct HealthDashboardView: View {
    @StateObject private var health = HealthManager()
    var body: some View {
        List {
            Section {
                if health.isAvailable {
                    Button { Task { await health.requestAccessAndLoad() } } label: { Label("连接 Apple 健康", systemImage: "heart.text.square") }
                    Button("刷新数据") { Task { await health.refresh() } }.disabled(health.isLoading)
                } else { Text("这台设备不支持 HealthKit。").foregroundStyle(.secondary) }
            } footer: { Text("戒刻仅读取步数、心率和睡眠，用于帮助你观察戒烟期间的生活状态；不会上传到服务器。") }
            Section("今日健康数据") {
                LabeledContent("步数", value: health.stepCount.formatted())
                LabeledContent("最近心率", value: health.heartRate.map { "\($0.formatted(.number.precision(.fractionLength(0)))) 次/分" } ?? "暂无数据")
                LabeledContent("近 24 小时睡眠", value: health.sleepHours.map { "\($0.formatted(.number.precision(.fractionLength(1)))) 小时" } ?? "暂无数据")
            }
            if let lastUpdated = health.lastUpdated { Section { Text("上次更新：\(lastUpdated.formatted(.dateTime.hour().minute()))").font(.footnote).foregroundStyle(.secondary) } }
            if let error = health.errorMessage { Section { Text(error).foregroundStyle(.red) } }
        }
        .navigationTitle("HealthKit")
        .overlay { if health.isLoading { ProgressView().controlSize(.large) } }
        .task { await health.refresh() }
    }
}
