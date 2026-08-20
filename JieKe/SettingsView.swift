import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [QuitProfile]
    @State private var notificationsEnabled = false
    var body: some View {
        List {
            if let profile = profiles.first { Section("戒烟资料") { ProfileSettingsForm(profile: profile) } }
            Section("提醒") { Toggle("戒烟提醒", isOn: $notificationsEnabled); Text("提醒权限将在后续版本中接入。").font(.caption).foregroundStyle(.secondary) }
            Section("健康与数据") { Label("HealthKit", systemImage: "heart.text.square"); Label("小组件", systemImage: "rectangle.3.group"); Label("数据导出", systemImage: "square.and.arrow.up") }
            Section("隐私") { Text("你的戒烟资料与记录目前仅保存在这台设备上。").font(.footnote) }
        }.navigationTitle("设置").toolbar { ToolbarItem(placement: .confirmationAction) { Button("完成") { dismiss() } } }
    }
}

private struct ProfileSettingsForm: View {
    @Bindable var profile: QuitProfile
    var body: some View {
        Stepper("每天 \(profile.cigarettesPerDay) 根", value: $profile.cigarettesPerDay, in: 1...100)
        Stepper("每包 \(profile.cigarettesPerPack) 根", value: $profile.cigarettesPerPack, in: 1...50)
        Stepper("烟龄 \(profile.smokingYears) 年", value: $profile.smokingYears, in: 0...80)
        DatePicker("戒烟开始时间", selection: $profile.quitDate)
        TextField("高风险场景", text: $profile.highRiskScenes, axis: .vertical)
    }
}

