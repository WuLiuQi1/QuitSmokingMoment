import SwiftUI

struct AchievementsView: View {
    let metrics: QuitMetrics

    private var unlockedCount: Int { metrics.achievements.filter(\.isUnlocked).count }

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("已解锁 \(unlockedCount) 枚成就")
                            .font(.title2.bold())
                        Text("每一次忍住、每一天坚持，都会留下你的戒烟足迹。")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .liquidGlassCard(tint: .yellow.opacity(0.12), cornerRadius: 20)

                    Text("成就徽章")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(metrics.achievements) { achievement in
                            AchievementBadge(achievement: achievement)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("我的成就")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AchievementBadge: View {
    let achievement: QuitAchievement

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: achievement.isUnlocked ? achievement.symbol : "lock.fill")
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? achievement.tint : .secondary)
                .frame(width: 48, height: 48)
                .background((achievement.isUnlocked ? achievement.tint : Color.secondary).opacity(0.15), in: Circle())
            Text(achievement.title)
                .font(.headline)
                .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
            Text(achievement.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            if achievement.isUnlocked {
                Text("已解锁")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(achievement.tint)
            } else {
                Text("未解锁")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 175, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: achievement.isUnlocked ? achievement.tint.opacity(0.10) : nil, cornerRadius: 20)
    }
}
