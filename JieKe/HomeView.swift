import SwiftData
import SwiftUI

struct HomeView: View {
    @Query private var profiles: [QuitProfile]
    @Query(sort: \CravingRecord.createdAt, order: .reverse) private var records: [CravingRecord]
    @Query(sort: \DailyReflection.createdAt, order: .reverse) private var reflections: [DailyReflection]
    @State private var showsRescue = false
    @State private var showsSettings = false
    @State private var showsAchievements = false
    @State private var showsHealthMilestones = false
    @State private var showsDailyPlan = false
    @State private var showsDailyReflection = false
    @State private var showsEducation = false

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            if let profile = profiles.first {
                let metrics = QuitMetrics(profile: profile, records: records, now: timeline.date)
                ZStack {
                    LiquidGlassBackdrop()
                    ScrollView {
                        VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Text("已戒烟").foregroundStyle(.secondary)
                            Text(metrics.elapsedText).font(.system(.largeTitle, design: .rounded, weight: .bold)).contentTransition(.numericText())
                            Text(profile.quitDate, format: .dateTime.year().month().day().hour().minute()).font(.caption).foregroundStyle(.secondary)
                            Label("连续无复吸 \(metrics.relapseFreeText)", systemImage: "flame.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 28)
                        .liquidGlassCard(tint: .mint.opacity(0.18))
                        HStack(spacing: 10) {
                            MetricCard(title: "少抽", value: "\(metrics.avoidedCigarettesText) 根", symbol: "lungs.fill")
                            MetricCard(title: "节省", value: metrics.savedMoney.formatted(.currency(code: "CNY")), symbol: "yensign.circle.fill")
                            MetricCard(title: "今日烟瘾", value: "\(metrics.todayCravings) 次", symbol: "waveform.path.ecg")
                        }
                        Text("每成功忍住 1 次，计为少抽 1 支；已成功度过 \(metrics.successfullyHandledCravings) 次烟瘾。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Button { showsRescue = true } label: { Label("我现在想抽烟", systemImage: "shield.lefthalf.filled").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 10) }
                            .tint(.blue)
                            .liquidGlassProminentButton()
                            .controlSize(.large)
                        DailyPlanCard(successCount: records.filter { !$0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count) {
                            showsDailyPlan = true
                        }
                        DailyReflectionCard(
                            successCount: records.filter { !$0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count,
                            relapseCount: records.filter { $0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count,
                            reflection: reflections.first(where: { Calendar.current.isDateInToday($0.createdAt) })
                        ) {
                            showsDailyReflection = true
                        }
                        Button { showsEducation = true } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "book.closed.fill")
                                    .font(.title3)
                                    .foregroundStyle(.teal)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("戒烟科普")
                                        .font(.headline)
                                    Text("了解危害、发现诱因，学习科学戒烟。")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .liquidGlassCard(tint: .teal.opacity(0.10), cornerRadius: 18)
                        }
                        .buttonStyle(.plain)
                        if let insight = RiskInsight.from(records: records) {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("高风险提示", systemImage: "exclamationmark.shield.fill")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                                Text("你在 \(insight.timeText) 前后更容易想抽烟")
                                    .font(.title3.bold())
                                Text("常见诱因：\(insight.trigger)。提前准备一杯水或走动两分钟。")
                                    .foregroundStyle(.secondary)
                                Button("提前开始急救") { showsRescue = true }
                                    .buttonStyle(.bordered)
                                    .tint(.orange)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .liquidGlassCard(tint: .orange.opacity(0.12), cornerRadius: 18)
                        }
                        Button { showsHealthMilestones = true } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Label("健康里程碑", systemImage: metrics.milestone.symbol).font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption.weight(.bold)).foregroundStyle(.tertiary)
                                }
                                Text(metrics.milestone.title).font(.title3.bold())
                                Text(metrics.milestone.benefit).foregroundStyle(.secondary)
                                if let next = metrics.nextHealthMilestone {
                                    Text("下一阶段：\(next.title) · \(next.remainingText)")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(next.tint)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .liquidGlassCard(tint: .green.opacity(0.12), cornerRadius: 18)
                        }
                        .buttonStyle(.plain)

                        AchievementPreview(metrics: metrics) {
                            showsAchievements = true
                        }
                    }
                    .padding()
                }
                .onAppear { publishSystemSurfaces(profile: profile) }
                .onChange(of: records.count) { _, _ in publishSystemSurfaces(profile: profile) }
                }
            }
        }
        .navigationTitle("戒刻")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("设置", systemImage: "gearshape") { showsSettings = true } } }
        .sheet(isPresented: $showsRescue) { NavigationStack { CravingRescueView() } }
        .sheet(isPresented: $showsSettings) { NavigationStack { SettingsView() } }
        .sheet(isPresented: $showsAchievements) {
            NavigationStack { AchievementsView(metrics: QuitMetrics(profile: profiles.first!, records: records, now: .now)) }
        }
        .sheet(isPresented: $showsHealthMilestones) {
            NavigationStack { HealthMilestonesView(metrics: QuitMetrics(profile: profiles.first!, records: records, now: .now)) }
        }
        .sheet(isPresented: $showsDailyPlan) {
            NavigationStack {
                DailyPlanView(
                    successCount: records.filter { !$0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count,
                    weeklySuccessCount: records.filter { !$0.didSmoke && SummaryPeriod.week.contains($0.createdAt) }.count,
                    savedMoney: QuitMetrics(profile: profiles.first!, records: records, now: .now).savedMoney
                )
            }
        }
        .sheet(isPresented: $showsDailyReflection) {
            NavigationStack { DailyReflectionView(reflection: reflections.first(where: { Calendar.current.isDateInToday($0.createdAt) }), successCount: records.filter { !$0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count, relapseCount: records.filter { $0.didSmoke && Calendar.current.isDateInToday($0.createdAt) }.count) }
        }
        .sheet(isPresented: $showsEducation) { NavigationStack { QuitSmokingEducationView() } }
    }

    private func publishSystemSurfaces(profile: QuitProfile) {
        WidgetDataStore.publish(profile: profile, records: records)
        Task { await LiveActivityManager.update(profile: profile, records: records) }
    }
}

private struct AchievementPreview: View {
    let metrics: QuitMetrics
    let action: () -> Void

    var body: some View {
        let unlocked = metrics.achievements.filter(\.isUnlocked).count
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("我的成就", systemImage: "medal.fill")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                    Spacer()
                    Text("\(unlocked)/\(metrics.achievements.count)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                if let next = metrics.nextAchievement {
                    Text("下一枚：\(next.title)")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text(next.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("全部解锁")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("你的每一次坚持都值得被记住。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .liquidGlassCard(tint: .yellow.opacity(0.12), cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

private struct MetricCard: View {
    let title: String; let value: String; let symbol: String
    var body: some View {
        VStack(spacing: 8) { Image(systemName: symbol).foregroundStyle(.tint); Text(value).font(.headline).lineLimit(1).minimumScaleFactor(0.75); Text(title).font(.caption).foregroundStyle(.secondary) }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
            .liquidGlassCard(cornerRadius: 16)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title)：\(value)")
    }
}
