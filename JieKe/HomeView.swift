import SwiftUI

struct HomeView: View {
    @State private var showsRescue = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("已戒烟")
                        .foregroundStyle(.secondary)
                    Text("0 天 0 小时")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)

                HStack(spacing: 12) {
                    MetricCard(title: "少抽", value: "0 根", symbol: "lungs.fill")
                    MetricCard(title: "节省", value: "¥0", symbol: "yensign.circle.fill")
                    MetricCard(title: "今日烟瘾", value: "0 次", symbol: "waveform.path.ecg")
                }

                Button {
                    showsRescue = true
                } label: {
                    Label("我现在想抽烟", systemImage: "shield.lefthalf.filled")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                ContentUnavailableView(
                    "健康里程碑",
                    systemImage: "heart.text.square",
                    description: Text("坚持戒烟后，这里会显示身体恢复进度。")
                )
            }
            .padding()
        }
        .navigationTitle("戒刻")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("设置", systemImage: "gearshape") { }
            }
        }
        .sheet(isPresented: $showsRescue) {
            NavigationStack { CravingRescueView() }
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            Text(value).font(.headline)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }
}

