import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [QuitProfile]
    @Query private var records: [CravingRecord]
    @Query private var reflections: [DailyReflection]
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("highRiskReminderEnabled") private var highRiskReminderEnabled = false
    @AppStorage("achievementNotificationsEnabled") private var achievementNotificationsEnabled = false
    @AppStorage("healthMilestoneNotificationsEnabled") private var healthMilestoneNotificationsEnabled = false
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false
    @AppStorage("reduceMotionInApp") private var reduceMotionInApp = false
    @AppStorage("highContrastInApp") private var highContrastInApp = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    @State private var notificationError = false
    @State private var exportURL: URL?
    @State private var showsExportSheet = false
    @State private var exportError = false
    @State private var backupURL: URL?
    @State private var showsBackupSheet = false
    @State private var showsBackupImporter = false
    @State private var pendingBackup: BackupArchive?
    @State private var showsRestoreConfirmation = false
    @State private var restoreError = false
    var body: some View {
        List {
            if let profile = profiles.first { Section("戒烟资料") { ProfileSettingsForm(profile: profile) } }
            Section("提醒") {
                Toggle("每日戒烟提醒", isOn: $notificationsEnabled)
                if notificationsEnabled { DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute) }
                if let insight = RiskInsight.from(records: records) {
                    Toggle("高风险时段提醒", isOn: $highRiskReminderEnabled)
                    Text("根据记录推测，你在 \(insight.timeText) 前后较易想抽烟；会提前发送提醒。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("累积至少 2 次高强度烟瘾或复吸记录后，可开启高风险时段提醒。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("提醒会在这台设备上本地发送。").font(.caption).foregroundStyle(.secondary)
            }
            Section("阶段提醒") {
                Toggle("成就解锁提醒", isOn: $achievementNotificationsEnabled)
                Toggle("健康里程碑提醒", isOn: $healthMilestoneNotificationsEnabled)
                Text("成就和健康阶段达到时，会在本机显示提醒。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("健康与数据") {
                Label("HealthKit（即将推出）", systemImage: "heart.text.square")
                Label("小组件（即将推出）", systemImage: "rectangle.3.group")
                Button { exportRecords() } label: { Label("导出记录 CSV", systemImage: "square.and.arrow.up") }
                Button { exportBackup() } label: { Label("导出完整备份", systemImage: "externaldrive.badge.checkmark") }
                Button { showsBackupImporter = true } label: { Label("从备份恢复", systemImage: "externaldrive.badge.plus") }
                Text("完整备份包含戒烟资料、记录、复盘及附件。恢复会替换当前本机数据。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("隐私") {
                Toggle("打开应用时验证身份", isOn: $privacyLockEnabled)
                NavigationLink { PasscodeSettingsView() } label: { Label("设置独立密码", systemImage: "key.fill") }
                Text("开启后，应用回到前台时需要 Face ID 或设备密码解锁。你的戒烟资料与记录仍只保存在这台设备上。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("辅助功能") {
                Toggle("减少应用内动态效果", isOn: $reduceMotionInApp)
                Toggle("增强卡片对比度", isOn: $highContrastInApp)
                Text("系统的动态字体、深色模式与 VoiceOver 会自动遵循设备设置。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("设置")
        .onAppear {
            reminderTime = Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
        }
        .onChange(of: notificationsEnabled) { _, enabled in
            Task {
                if enabled {
                    let allowed = await NotificationManager.requestAuthorization()
                    if allowed { await saveReminder() }
                    else { notificationsEnabled = false; notificationError = true }
                } else {
                    NotificationManager.cancelDailyReminder()
                }
            }
        }
        .onChange(of: reminderTime) { _, _ in
            guard notificationsEnabled else { return }
            Task { await saveReminder() }
        }
        .onChange(of: highRiskReminderEnabled) { _, enabled in
            Task {
                guard enabled else { NotificationManager.cancelRiskReminder(); return }
                let allowed = await NotificationManager.requestAuthorization()
                guard allowed, let insight = RiskInsight.from(records: records) else {
                    highRiskReminderEnabled = false
                    notificationError = true
                    return
                }
                await NotificationManager.scheduleRiskReminder(for: insight)
            }
        }
        .onChange(of: achievementNotificationsEnabled) { _, enabled in
            Task {
                guard enabled else { return }
                let allowed = await NotificationManager.requestAuthorization()
                if !allowed { achievementNotificationsEnabled = false; notificationError = true }
            }
        }
        .onChange(of: healthMilestoneNotificationsEnabled) { _, enabled in
            Task {
                guard enabled else { NotificationManager.cancelHealthMilestoneReminder(); return }
                let allowed = await NotificationManager.requestAuthorization()
                guard allowed, let profile = profiles.first else {
                    healthMilestoneNotificationsEnabled = false
                    notificationError = true
                    return
                }
                await NotificationManager.scheduleNextHealthMilestone(after: profile.quitDate)
            }
        }
        .alert("未获得通知权限", isPresented: $notificationError) {
            Button("好", role: .cancel) { }
        } message: {
            Text("请在系统设置中允许“戒刻”发送通知后再开启提醒。")
        }
        .alert("导出失败", isPresented: $exportError) {
            Button("好", role: .cancel) { }
        } message: {
            Text("暂时无法生成导出文件，请稍后再试。")
        }
        .sheet(isPresented: $showsExportSheet) {
            if let exportURL { ActivityShareSheet(items: [exportURL]) }
        }
        .sheet(isPresented: $showsBackupSheet) {
            if let backupURL { ActivityShareSheet(items: [backupURL]) }
        }
        .fileImporter(isPresented: $showsBackupImporter, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                pendingBackup = try BackupManager.load(from: url)
                showsRestoreConfirmation = true
            } catch {
                restoreError = true
            }
        }
        .alert("恢复备份？", isPresented: $showsRestoreConfirmation) {
            Button("取消", role: .cancel) { pendingBackup = nil }
            Button("替换并恢复", role: .destructive) { restoreBackup() }
        } message: {
            Text("当前的戒烟资料、记录和复盘将被备份文件中的内容替换。")
        }
        .alert("恢复失败", isPresented: $restoreError) {
            Button("好", role: .cancel) { }
        } message: {
            Text("请选择由戒刻导出的完整 JSON 备份文件。")
        }
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
    }

    private func saveReminder() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        reminderHour = components.hour ?? 20
        reminderMinute = components.minute ?? 0
        await NotificationManager.scheduleDailyReminder(at: reminderTime)
    }

    private func exportRecords() {
        do {
            exportURL = try CSVExporter.export(records: records)
            showsExportSheet = true
        } catch {
            exportError = true
        }
    }

    private func exportBackup() {
        do {
            backupURL = try BackupManager.export(profile: profiles.first, records: records, reflections: reflections)
            showsBackupSheet = true
        } catch {
            exportError = true
        }
    }

    private func restoreBackup() {
        guard let pendingBackup else { return }
        do {
            try BackupManager.restore(pendingBackup, profiles: profiles, records: records, reflections: reflections, context: modelContext)
            self.pendingBackup = nil
        } catch {
            restoreError = true
        }
    }
}

private struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

private struct ProfileSettingsForm: View {
    @Bindable var profile: QuitProfile
    var body: some View {
        Stepper("每天 \(profile.cigarettesPerDay) 根", value: $profile.cigarettesPerDay, in: 1...100)
        Stepper("每包 \(profile.cigarettesPerPack) 根", value: $profile.cigarettesPerPack, in: 1...50)
        Stepper("烟龄 \(profile.smokingYears) 年", value: $profile.smokingYears, in: 0...80)
        Stepper("每支焦油 \(profile.tarMilligramsPerCigarette.formatted(.number.precision(.fractionLength(1)))) mg", value: $profile.tarMilligramsPerCigarette, in: 0...30, step: 0.5)
        DatePicker("戒烟开始时间", selection: $profile.quitDate)
        TextField("高风险场景", text: $profile.highRiskScenes, axis: .vertical)
    }
}
