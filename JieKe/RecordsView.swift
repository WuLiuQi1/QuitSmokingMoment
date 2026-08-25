import SwiftData
import SwiftUI

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CravingRecord.createdAt, order: .reverse) private var records: [CravingRecord]
    @State private var showsEditor = false
    @State private var selectedRecord: CravingRecord?
    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            Group {
                if records.isEmpty {
                    ContentUnavailableView("还没有记录", systemImage: "square.and.pencil", description: Text("记录烟瘾、心情和诱因，更了解自己的戒烟过程。"))
                        .foregroundStyle(.white)
                } else {
                    List {
                        ForEach(records) { record in
                            RecordRow(record: record)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedRecord = record }
                                .swipeActions {
                                    Button(role: .destructive) { modelContext.delete(record) } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
        }.navigationTitle("记录")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("添加记录", systemImage: "plus") { showsEditor = true } } }
            .sheet(isPresented: $showsEditor) { NavigationStack { RecordEditorView() } }
            .sheet(item: $selectedRecord) { record in NavigationStack { RecordEditorView(record: record) } }
    }
}

private struct RecordRow: View {
    let record: CravingRecord
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.didSmoke ? "exclamationmark.triangle.fill" : "checkmark.circle.fill").foregroundStyle(record.didSmoke ? .orange : .green)
            VStack(alignment: .leading, spacing: 4) {
                Text(record.didSmoke ? "已抽烟 \(record.cigaretteCount) 根" : "成功忍住了")
                Text("强度 \(record.intensity) · \(record.mood)\(record.trigger.isEmpty ? "" : " · \(record.trigger)")").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(); Text(record.createdAt, format: .dateTime.month().day().hour().minute()).font(.caption).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .liquidGlassCard(cornerRadius: 18)
    }
}

struct RecordEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    private let record: CravingRecord?
    @State private var intensity = 5
    @State private var mood = RecordChoices.moods[0]
    @State private var trigger = RecordChoices.triggers[0]
    @State private var didSmoke = false
    @State private var cigaretteCount = 1
    @State private var note = ""

    init(record: CravingRecord? = nil) {
        self.record = record
        _intensity = State(initialValue: record?.intensity ?? 5)
        _mood = State(initialValue: record?.mood ?? RecordChoices.moods[0])
        _trigger = State(initialValue: record?.trigger ?? RecordChoices.triggers[0])
        _didSmoke = State(initialValue: record?.didSmoke ?? false)
        _cigaretteCount = State(initialValue: max(1, record?.cigaretteCount ?? 1))
        _note = State(initialValue: record?.note ?? "")
    }
    var body: some View {
        Form {
            Section("此刻感受") {
                Picker("烟瘾强度", selection: $intensity) { ForEach(1...10, id: \.self) { Text("\($0) / 10") } }
                Picker("心情", selection: $mood) { ForEach(RecordChoices.moods, id: \.self) { Text($0) } }
                Picker("诱因", selection: $trigger) { ForEach(RecordChoices.triggers, id: \.self) { Text($0) } }
            }
            Section("结果") { Toggle("这次抽烟了", isOn: $didSmoke); if didSmoke { Stepper("抽了 \(cigaretteCount) 根", value: $cigaretteCount, in: 1...20) } }
            Section("备注") { TextField("写下当时发生的事（可选）", text: $note, axis: .vertical) }
        }.navigationTitle(record == nil ? "添加记录" : "编辑记录")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("保存") { save() } } }
    }
    private func save() {
        if let record {
            record.intensity = intensity
            record.trigger = trigger
            record.mood = mood
            record.note = note
            record.didSmoke = didSmoke
            record.cigaretteCount = didSmoke ? cigaretteCount : 0
        } else {
            modelContext.insert(CravingRecord(intensity: intensity, trigger: trigger, mood: mood, note: note, didSmoke: didSmoke, cigaretteCount: didSmoke ? cigaretteCount : 0))
        }
        dismiss()
    }
}
