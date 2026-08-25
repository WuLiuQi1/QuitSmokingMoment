import SwiftUI

struct DailyPlanCard: View {
    let successCount: Int
    let openPlan: () -> Void
    @AppStorage("dailyResistGoal") private var goal = 3
    @AppStorage("dailyPlanDate") private var storedDate = ""
    @AppStorage("dailyPlanActions") private var storedActions = ""

    private var todayKey: String { Date.now.formatted(.dateTime.year().month().day()) }
    private var completedActions: Set<String> { Set(storedActions.split(separator: ",").map(String.init)) }
    private var actionTitles: [String] { ["喝水", "走动", "深呼吸"] }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("今日计划", systemImage: "checklist")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                Spacer()
                Button(action: openPlan) {
                    Label("调整", systemImage: "slider.horizontal.3")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderless)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("忍住 \(min(successCount, goal)) / \(goal) 次")
                    .font(.title3.bold())
                Spacer()
                Text(successCount >= goal ? "今日目标已完成" : "再忍住 \(max(0, goal - successCount)) 次")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(successCount >= goal ? .green : .secondary)
            }
            ProgressView(value: Double(min(successCount, goal)), total: Double(max(goal, 1)))
                .tint(successCount >= goal ? .green : .indigo)
            HStack(spacing: 8) {
                ForEach(actionTitles, id: \.self) { title in
                    Button {
                        toggle(title)
                    } label: {
                        Label(title, systemImage: completedActions.contains(title) ? "checkmark.circle.fill" : "circle")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(completedActions.contains(title) ? .green : .primary)
                            .background(completedActions.contains(title) ? Color.green.opacity(0.12) : Color.clear, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: .indigo.opacity(0.10), cornerRadius: 18)
        .onAppear(perform: resetIfNeeded)
    }

    private func resetIfNeeded() {
        guard storedDate != todayKey else { return }
        storedDate = todayKey
        storedActions = ""
    }

    private func toggle(_ title: String) {
        resetIfNeeded()
        var actions = completedActions
        if actions.contains(title) { actions.remove(title) } else { actions.insert(title) }
        storedActions = actions.sorted().joined(separator: ",")
    }
}

struct DailyPlanView: View {
    let successCount: Int
    let weeklySuccessCount: Int
    let savedMoney: Double
    @AppStorage("dailyResistGoal") private var goal = 3
    @AppStorage("weeklyResistGoal") private var weeklyGoal = 12
    @AppStorage("savingsGoal") private var savingsGoal = 100
    @AppStorage("dailyPlanDate") private var storedDate = ""
    @AppStorage("dailyPlanActions") private var storedActions = ""

    private var todayKey: String { Date.now.formatted(.dateTime.year().month().day()) }
    private var completedActions: [String] { storedActions.split(separator: ",").map(String.init).sorted() }

    var body: some View {
        Form {
            Section("今天的目标") {
                Stepper("成功忍住 \(goal) 次", value: $goal, in: 1...20)
                ProgressView(value: Double(min(successCount, goal)), total: Double(max(goal, 1)))
                    .tint(successCount >= goal ? .green : .indigo)
                Text(successCount >= goal ? "今天的目标已经完成，继续保持。" : "今天已成功忍住 \(successCount) 次，还差 \(goal - successCount) 次。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("个性化目标") {
                Stepper("本周成功忍住 \(weeklyGoal) 次", value: $weeklyGoal, in: 1...100)
                ProgressView(value: Double(min(weeklySuccessCount, weeklyGoal)), total: Double(max(weeklyGoal, 1)))
                    .tint(weeklySuccessCount >= weeklyGoal ? .green : .blue)
                Text("本周已成功忍住 \(weeklySuccessCount) 次。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Stepper("累计节省 ¥\(savingsGoal)", value: $savingsGoal, in: 10...10_000, step: 10)
                ProgressView(value: min(savedMoney, Double(savingsGoal)), total: Double(savingsGoal))
                    .tint(savedMoney >= Double(savingsGoal) ? .green : .mint)
                Text("累计已节省 \(savedMoney.formatted(.currency(code: "CNY")))。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("今日戒烟行动") {
                if completedActions.isEmpty {
                    Text("还没有完成行动。首页可以勾选喝水、走动和深呼吸。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(completedActions, id: \.self) { action in
                        Label(action, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            Section {
                Text("计划每天会自动重新开始；“忍住次数”以实际保存的成功烟瘾记录为准。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("每日计划")
        .onAppear {
            if storedDate != todayKey {
                storedDate = todayKey
                storedActions = ""
            }
        }
    }
}
