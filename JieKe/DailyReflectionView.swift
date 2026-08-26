import SwiftData
import SwiftUI

struct DailyReflectionCard: View {
    let successCount: Int
    let relapseCount: Int
    let reflection: DailyReflection?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Label("今日复盘", systemImage: "text.book.closed.fill")
                        .font(.headline)
                        .foregroundStyle(.purple)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                if let reflection, !reflection.note.isEmpty {
                    Text(reflection.note)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text("心情：\(reflection.mood)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("今天成功少吸 \(successCount) 次，复吸 \(relapseCount) 次。")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("花一分钟记下今天的感受，为明天做准备。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .liquidGlassCard(tint: .purple.opacity(0.10), cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

struct DailyReflectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    private let reflection: DailyReflection?
    private let successCount: Int
    private let relapseCount: Int
    @State private var mood: String
    @State private var note: String

    init(reflection: DailyReflection?, successCount: Int, relapseCount: Int) {
        self.reflection = reflection
        self.successCount = successCount
        self.relapseCount = relapseCount
        _mood = State(initialValue: reflection?.mood ?? RecordChoices.moods[0])
        _note = State(initialValue: reflection?.note ?? "")
    }

    var body: some View {
        Form {
            Section("今日摘要") {
                LabeledContent("成功少吸", value: "\(successCount) 次")
                LabeledContent("复吸", value: "\(relapseCount) 次")
            }
            Section("今天感觉如何") {
                Picker("心情", selection: $mood) {
                    ForEach(RecordChoices.moods, id: \.self) { Text($0) }
                }
                TextField("写下今天最难的时刻、最有用的方法，或想对自己说的话", text: $note, axis: .vertical)
                    .lineLimit(4...8)
            }
            Section {
                Text("复盘不是评判。真实地记录，会帮助你发现下一次更适合自己的应对方法。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("今日复盘")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } }
        }
    }

    private func save() {
        if let reflection {
            reflection.mood = mood
            reflection.note = note
        } else {
            modelContext.insert(DailyReflection(mood: mood, note: note))
        }
        dismiss()
    }
}
