import SwiftUI

struct CravingRescueView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var intensity = 5.0

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "wind")
                .font(.system(size: 72))
                .foregroundStyle(.blue)
                .symbolEffect(.pulse)
            Text("先陪自己呼吸一分钟")
                .font(.title2.bold())
            Text("慢慢吸气，再缓缓呼气。烟瘾会像浪一样退去。")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading) {
                Text("当前强度：\(Int(intensity)) / 10")
                Slider(value: $intensity, in: 1...10, step: 1)
            }

            HStack {
                Label("喝水", systemImage: "drop.fill")
                Spacer()
                Label("走动", systemImage: "figure.walk")
                Spacer()
                Label("转移注意", systemImage: "sparkles")
            }
            .font(.subheadline)

            Button("我坚持过去了") { dismiss() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .navigationTitle("烟瘾急救")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("关闭") { dismiss() }
            }
        }
    }
}

