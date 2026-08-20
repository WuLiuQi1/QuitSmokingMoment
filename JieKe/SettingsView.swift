import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [QuitProfile]
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? .now
    @State private var notificationError = false
    var body: some View {
        List {
            if let profile = profiles.first { Section("戒烟资料") { ProfileSettingsForm(profile: profile) } }
            Section("提醒") {
                Toggle("每日戒烟提醒", isOn: $notificationsEnabled)
                if notificationsEnabled { DatePicker("提醒时间", selection: $reminderTime, displayedComponents: .hourAndMinute) }
                Text("提醒会在这台设备上本地发送。").font(.caption).foregroundStyle(.secondary)
            }
            Section("健康与数据") { Label("HealthKit（即将推出）", systemImage: "heart.text.square"); Label("小组件（即将推出）", systemImage: "rectangle.3.group"); Label("数据导出（即将推出）", systemImage: "square.and.arrow.up") }
            Section("隐私") { Text("你的戒烟资料与记录目前仅保存在这台设备上。").font(.footnote) }
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
        .alert("未获得通知权限", isPresented: $notificationError) {
            Button("好", role: .cancel) { }
        } message: {
            Text("请在系统设置中允许“戒刻”发送通知后再开启提醒。")
        }
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
    }

    private func saveReminder() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        reminderHour = components.hour ?? 20
        reminderMinute = components.minute ?? 0
        await NotificationManager.scheduleDailyReminder(at: reminderTime)
    }
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
