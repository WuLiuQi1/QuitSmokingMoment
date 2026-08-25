import Combine
import SwiftData
import SwiftUI

struct CravingRescueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var intensity = 5.0
    @State private var startedAt = Date()
    @State private var now = Date()
    @State private var isExpanded = false
    @State private var showsRelapseSheet = false
    @State private var cigaretteCount = 1
    @State private var recoveryPlan = ""
    @State private var mood = RecordChoices.moods[0]
    @State private var trigger = RecordChoices.triggers[0]
    private let duration = 180.0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var remaining: Int { max(0, Int(duration - now.timeIntervalSince(startedAt))) }

    var body: some View {
        ScrollView {
        VStack(spacing: 26) {
            Text("给自己 3 分钟").font(.title2.bold())
            ZStack {
                Circle().fill(.blue.opacity(0.12)).frame(width: 190, height: 190)
                Circle().fill(.blue.opacity(0.2)).frame(width: isExpanded ? 150 : 105, height: isExpanded ? 150 : 105).animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isExpanded)
                VStack { Text("慢慢呼吸").font(.headline); Text("\(remaining / 60):\(String(format: "%02d", remaining % 60))").font(.system(.title, design: .rounded, weight: .bold)) }
            }
            .onAppear { isExpanded = true }
            .liquidGlassCard(tint: .blue.opacity(0.35), cornerRadius: 95)
            Text("吸气 4 秒，停住 2 秒，呼气 6 秒。烟瘾会像浪一样退去。").multilineTextAlignment(.center).foregroundStyle(.secondary)
            VStack(alignment: .leading) { Text("当前强度：\(Int(intensity)) / 10"); Slider(value: $intensity, in: 1...10, step: 1) }
                .padding()
                .liquidGlassCard(cornerRadius: 18)
            HStack { RescueTip(title: "喝水", symbol: "drop.fill"); Spacer(); RescueTip(title: "走动", symbol: "figure.walk"); Spacer(); RescueTip(title: "转移注意", symbol: "sparkles") }
                .padding()
                .liquidGlassCard(cornerRadius: 18)
            HStack(spacing: 12) {
                RescueChoice(title: "诱因", selection: $trigger, options: RecordChoices.triggers)
                RescueChoice(title: "心情", selection: $mood, options: RecordChoices.moods)
            }
            Button("我坚持过去了") { saveSuccess() }.buttonStyle(.borderedProminent).controlSize(.large).frame(maxWidth: .infinity)
            Button("我没忍住", role: .destructive) { showsRelapseSheet = true }
                .font(.subheadline)
        }.padding()
        }.onReceive(timer) { now = $0 }.navigationTitle("烟瘾急救").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("关闭") { dismiss() } } }
        .sheet(isPresented: $showsRelapseSheet) {
            NavigationStack {
                Form {
                    Section("这次抽了多少？") {
                        Stepper("\(cigaretteCount) 根", value: $cigaretteCount, in: 1...20)
                    }
                    Section("下一次怎么准备？") {
                        TextField("例如：饭后先散步 5 分钟", text: $recoveryPlan, axis: .vertical)
                        Text("一次复吸不代表前面的坚持白费。写下一个下一次能做到的小动作。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Section {
                        Text("如实记录不是失败。了解复吸发生的时刻，才能更好地准备下一次。")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("记录复吸")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("取消") { showsRelapseSheet = false } }
                    ToolbarItem(placement: .confirmationAction) { Button("保存") { saveRelapse() } }
                }
            }
            .presentationDetents([.medium])
        }
    }
    private func saveSuccess() { modelContext.insert(CravingRecord(intensity: Int(intensity), trigger: trigger, mood: mood)); dismiss() }
    private func saveRelapse() {
        modelContext.insert(CravingRecord(intensity: Int(intensity), trigger: trigger, mood: mood, note: recoveryPlan, didSmoke: true, cigaretteCount: cigaretteCount))
        dismiss()
    }
}

private struct RescueTip: View { let title: String; let symbol: String; var body: some View { Label(title, systemImage: symbol).font(.subheadline) } }

private struct RescueChoice: View {
    let title: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { selection = option }
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text(selection).font(.subheadline.weight(.semibold)).lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.up.chevron.down").font(.caption.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .liquidGlassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}
