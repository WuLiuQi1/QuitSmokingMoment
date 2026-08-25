import SwiftUI

struct HealthMilestonesView: View {
    let metrics: QuitMetrics

    var body: some View {
        ZStack {
            LiquidGlassBackdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("身体恢复时间线")
                        .font(.title2.bold())
                    Text("以下为一般健康信息，恢复速度因人而异；如有不适，请咨询医生。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    ForEach(metrics.healthMilestones) { milestone in
                        HealthMilestoneRow(milestone: milestone)
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("健康里程碑")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HealthMilestoneRow: View {
    let milestone: HealthMilestone

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: milestone.isCompleted ? "checkmark" : milestone.symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(milestone.isCompleted ? .white : milestone.tint)
                .frame(width: 42, height: 42)
                .background(milestone.isCompleted ? milestone.tint : milestone.tint.opacity(0.15), in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(milestone.title).font(.headline)
                    Spacer()
                    Text(milestone.remainingText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(milestone.isCompleted ? .green : .secondary)
                }
                Text(milestone.benefit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: milestone.isCompleted ? milestone.tint.opacity(0.10) : nil, cornerRadius: 18)
    }
}
