import Combine
import SwiftData
import SwiftUI

struct CravingRescueView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var records: [CravingRecord]
    @AppStorage("achievementNotificationsEnabled") private var achievementNotificationsEnabled = false
    @State private var intensity = 5.0
    @State private var startedAt = Date()
    @State private var now = Date()
    @State private var isExpanded = false
    @State private var showsRelapseSheet = false
    @State private var cigaretteCount = 1
    @State private var recoveryPlan = ""
    @State private var mood = RecordChoices.moods[0]
    @State private var trigger = RecordChoices.triggers[0]
    @State private var selectedAction: RescueAction?
    @State private var completedAction = false
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
            HStack(spacing: 4) {
                ForEach(RescueAction.allCases) { action in
                    Button {
                        selectedAction = action
                        completedAction = false
                    } label: {
                        RescueTip(action: action, isSelected: selectedAction == action)
                    }
                    .buttonStyle(.plain)
                }
            }
                .padding()
                .liquidGlassCard(cornerRadius: 18)
            HStack(spacing: 12) {
                RescueChoice(title: "诱因", selection: $trigger, options: RecordChoices.triggers)
                RescueChoice(title: "心情", selection: $mood, options: RecordChoices.moods)
            }
            if let action = selectedAction {
                VStack(alignment: .leading, spacing: 10) {
                    Label(action.title, systemImage: action.symbol).font(.headline)
                    Text(action.instruction).foregroundStyle(.secondary)
                    Button(completedAction ? "已完成" : "完成这个小动作") {
                        completedAction = true
                    }
                    .buttonStyle(.bordered)
                    .tint(completedAction ? .green : .blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .liquidGlassCard(tint: completedAction ? .green.opacity(0.14) : nil, cornerRadius: 18)
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
    private func saveSuccess() {
        let nextCount = records.filter { !$0.didSmoke }.count + 1
        modelContext.insert(CravingRecord(intensity: Int(intensity), trigger: trigger, mood: mood, copingMethod: selectedAction?.title ?? ""))
        if achievementNotificationsEnabled {
            let message: (String, String)?
            switch nextCount {
            case 1: message = ("解锁成就", "你成功度过了第一次烟瘾，继续保持。")
            case 10: message = ("解锁成就", "已成功忍住 10 次，每一次都很重要。")
            default: message = nil
            }
            if let message {
                Task { await NotificationManager.scheduleAchievement(title: message.0, body: message.1, identifier: "achievement-\(nextCount)") }
            }
        }
        dismiss()
    }
    private func saveRelapse() {
        modelContext.insert(CravingRecord(intensity: Int(intensity), trigger: trigger, mood: mood, note: recoveryPlan, copingMethod: selectedAction?.title ?? "", didSmoke: true, cigaretteCount: cigaretteCount))
        dismiss()
    }
}

private enum RescueAction: String, CaseIterable, Identifiable {
    case water, walk, distract

    var id: String { rawValue }
    var title: String {
        switch self {
        case .water: return "喝水"
        case .walk: return "走动"
        case .distract: return "转移注意"
        }
    }

    var symbol: String {
        switch self {
        case .water: return "drop.fill"
        case .walk: return "figure.walk"
        case .distract: return "sparkles"
        }
    }
    var instruction: String {
        switch self {
        case .water: "慢慢喝完一杯水，给身体一点新的感觉。"
        case .walk: "离开当前位置，走动两分钟，哪怕只是在房间里。"
        case .distract: "做一件需要双手或注意力的小事，直到下一次呼吸结束。"
        }
    }
}

private struct RescueTip: View {
    let action: RescueAction
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: action.symbol)
            Text(action.title).font(.caption.weight(.semibold))
        }
        .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 10))
    }
}

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
