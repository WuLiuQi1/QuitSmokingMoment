import SwiftUI

struct RecordChoiceSettingsView: View {
    @State private var customMoods = RecordChoiceStore.customMoods
    @State private var customTriggers = RecordChoiceStore.customTriggers
    @State private var newMood = ""
    @State private var newTrigger = ""

    var body: some View {
        List {
            Section("心情") {
                Text("预设：\(RecordChoices.defaultMoods.joined(separator: "、"))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ForEach(customMoods, id: \.self) { mood in
                    HStack {
                        Text(mood)
                        Spacer()
                        Button("删除", role: .destructive) { removeMood(mood) }
                            .font(.subheadline)
                    }
                }
                HStack {
                    TextField("添加自定义心情", text: $newMood)
                    Button("添加") { addMood() }
                        .disabled(newMood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section("诱因") {
                Text("预设：\(RecordChoices.defaultTriggers.joined(separator: "、"))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                ForEach(customTriggers, id: \.self) { trigger in
                    HStack {
                        Text(trigger)
                        Spacer()
                        Button("删除", role: .destructive) { removeTrigger(trigger) }
                            .font(.subheadline)
                    }
                }
                HStack {
                    TextField("添加自定义诱因", text: $newTrigger)
                    Button("添加") { addTrigger() }
                        .disabled(newTrigger.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }

            Section {
                Text("自定义选项会同时出现在“记录”和“烟瘾急救”的心情、诱因选择中。已保存的历史记录不会因删除自定义选项而改变。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("心情与诱因")
    }

    private func addMood() {
        RecordChoiceStore.addMood(newMood)
        newMood = ""
        customMoods = RecordChoiceStore.customMoods
    }

    private func addTrigger() {
        RecordChoiceStore.addTrigger(newTrigger)
        newTrigger = ""
        customTriggers = RecordChoiceStore.customTriggers
    }

    private func removeMood(_ mood: String) {
        RecordChoiceStore.removeMood(mood)
        customMoods = RecordChoiceStore.customMoods
    }

    private func removeTrigger(_ trigger: String) {
        RecordChoiceStore.removeTrigger(trigger)
        customTriggers = RecordChoiceStore.customTriggers
    }
}
