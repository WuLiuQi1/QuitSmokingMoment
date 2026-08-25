import SwiftData
import SwiftUI
import PhotosUI
import AVFoundation

struct RecordsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CravingRecord.createdAt, order: .reverse) private var records: [CravingRecord]
    @State private var showsEditor = false
    @State private var selectedRecord: CravingRecord?
    @State private var filter: RecordFilter = .all
    @State private var searchText = ""
    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            Group {
                if records.isEmpty {
                    ContentUnavailableView("还没有记录", systemImage: "square.and.pencil", description: Text("记录烟瘾、心情和诱因，更了解自己的戒烟过程。"))
                        .foregroundStyle(.white)
                } else {
                    List {
                        Section {
                            Picker("显示", selection: $filter) {
                                ForEach(RecordFilter.allCases) { Text($0.title).tag($0) }
                            }
                            .pickerStyle(.segmented)
                        }
                        ForEach(filteredRecords) { record in
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
            .searchable(text: $searchText, prompt: "搜索诱因、心情或备注")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("添加记录", systemImage: "plus") { showsEditor = true } } }
            .sheet(isPresented: $showsEditor) { NavigationStack { RecordEditorView() } }
            .sheet(item: $selectedRecord) { record in NavigationStack { RecordEditorView(record: record) } }
    }

    private var filteredRecords: [CravingRecord] {
        records.filter { record in
            let matchesFilter: Bool
            switch filter {
            case .all: matchesFilter = true
            case .success: matchesFilter = !record.didSmoke
            case .relapse: matchesFilter = record.didSmoke
            }
            guard matchesFilter else { return false }
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !query.isEmpty else { return true }
            return [record.trigger, record.mood, record.note, record.copingMethod]
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(query)
        }
    }
}

private enum RecordFilter: CaseIterable, Identifiable {
    case all, success, relapse
    var id: Self { self }
    var title: String {
        switch self {
        case .all: "全部"
        case .success: "忍住"
        case .relapse: "复吸"
        }
    }
}

private struct RecordRow: View {
    let record: CravingRecord
    @State private var audioPlayer: AVAudioPlayer?
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: record.didSmoke ? "exclamationmark.triangle.fill" : "checkmark.circle.fill").foregroundStyle(record.didSmoke ? .orange : .green)
            VStack(alignment: .leading, spacing: 4) {
                Text(record.didSmoke ? "已抽烟 \(record.cigaretteCount) 根" : "成功忍住了")
                Text("强度 \(record.intensity) · \(record.mood)\(record.trigger.isEmpty ? "" : " · \(record.trigger)")").font(.caption).foregroundStyle(.secondary)
                if record.attachmentImageData != nil || record.voiceMemoData != nil {
                    Label("含附件", systemImage: record.voiceMemoData != nil ? "photo.on.rectangle.angled" : "photo")
                        .font(.caption)
                        .foregroundStyle(.tint)
                }
                if let voiceData = record.voiceMemoData {
                    Button {
                        audioPlayer = try? AVAudioPlayer(data: voiceData)
                        audioPlayer?.play()
                    } label: {
                        Label("播放语音备注", systemImage: "play.circle.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.borderless)
                }
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
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var attachmentImageData: Data?
    @StateObject private var voiceRecorder = VoiceMemoRecorder()

    init(record: CravingRecord? = nil) {
        self.record = record
        _intensity = State(initialValue: record?.intensity ?? 5)
        _mood = State(initialValue: record?.mood ?? RecordChoices.moods[0])
        _trigger = State(initialValue: record?.trigger ?? RecordChoices.triggers[0])
        _didSmoke = State(initialValue: record?.didSmoke ?? false)
        _cigaretteCount = State(initialValue: max(1, record?.cigaretteCount ?? 1))
        _note = State(initialValue: record?.note ?? "")
        _attachmentImageData = State(initialValue: record?.attachmentImageData)
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
            Section("附件") {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(attachmentImageData == nil ? "添加照片" : "更换照片", systemImage: "photo")
                }
                if let attachmentImageData, let image = UIImage(data: attachmentImageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button("移除照片", role: .destructive) { self.attachmentImageData = nil }
                }
                if voiceRecorder.isRecording {
                    Button("停止录音", role: .destructive) { voiceRecorder.stop() }
                } else {
                    Button(voiceRecorder.hasRecording ? "重新录制语音" : "录制语音备注") { voiceRecorder.start() }
                }
                if voiceRecorder.hasRecording {
                    Label("已添加语音备注", systemImage: "waveform")
                        .foregroundStyle(.tint)
                    Button("移除语音", role: .destructive) { voiceRecorder.remove() }
                }
                if let error = voiceRecorder.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(.red)
                }
            }
        }.navigationTitle(record == nil ? "添加记录" : "编辑记录")
            .onAppear { voiceRecorder.load(record?.voiceMemoData) }
            .onChange(of: selectedPhoto) { _, item in
                guard let item else { return }
                Task { attachmentImageData = try? await item.loadTransferable(type: Data.self) }
            }
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
            record.attachmentImageData = attachmentImageData
            record.voiceMemoData = voiceRecorder.data
        } else {
            modelContext.insert(CravingRecord(intensity: intensity, trigger: trigger, mood: mood, note: note, didSmoke: didSmoke, cigaretteCount: didSmoke ? cigaretteCount : 0, attachmentImageData: attachmentImageData, voiceMemoData: voiceRecorder.data))
        }
        dismiss()
    }
}
