import SwiftUI
import UIKit

struct FocusGameView: View {
    @Environment(\.dismiss) private var dismiss
    let onCompleted: () -> Void

    @State private var remainingSeconds = 120
    @State private var gameTimer: Timer?
    @State private var score = 0
    @State private var target = UnitPoint(x: 0.5, y: 0.5)
    @State private var isFinished = false
    private var remaining: Int { max(0, remainingSeconds) }

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Label("专注点点乐", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                Text(isFinished ? "你完成了两分钟的转移注意" : "把注意力放在每一个蓝色光点上")
                    .font(.title3.bold())
                Text(isFinished ? "现在可以回到急救页，记录这一次少吸。" : "每点一次，给自己一次不点烟的选择。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack {
                Label {
                    Text("专注 ") + Text(score.description) + Text(" 次")
                } icon: {
                    Image(systemName: "hand.tap.fill")
                }
                Spacer()
                Text(isFinished ? "完成" : timeText)
                    .monospacedDigit()
                    .font(.headline)
                    .foregroundStyle(isFinished ? .green : .indigo)
            }
            .font(.subheadline.weight(.semibold))
            .padding()
            .liquidGlassCard(tint: .indigo.opacity(0.12), cornerRadius: 18)

            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.blue.opacity(0.10))
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.blue.opacity(0.18), lineWidth: 1)

                    if isFinished {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.green)
                            Text("两分钟完成")
                                .font(.title2.bold())
                            Text("你已经为自己争取到了一个缓冲。")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Button(action: moveTarget) {
                            ZStack {
                                Circle().fill(.blue.opacity(0.20)).frame(width: 86, height: 86)
                                Circle().fill(.blue).frame(width: 58, height: 58)
                                Image(systemName: "hand.tap.fill")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                            }
                            .shadow(color: .blue.opacity(0.30), radius: 12, y: 6)
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: max(54, min(proxy.size.width - 54, target.x * proxy.size.width)),
                            y: max(54, min(proxy.size.height - 54, target.y * proxy.size.height))
                        )
                        .accessibilityLabel("专注光点，点按一次")
                    }
                }
            }
            .frame(height: 330)
            .liquidGlassCard(tint: .blue.opacity(0.10), cornerRadius: 30)

            if isFinished {
                Button("回到急救页，记录少吸") {
                    onCompleted()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
            } else {
                Text("游戏不计分胜负，只帮你把这两分钟留给自己。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(LiquidGlassBackdrop())
        .navigationTitle("烟瘾急救小游戏")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("退出") { dismiss() }
            }
        }
        .onAppear {
            remainingSeconds = 120
            isFinished = false
            target = randomTarget
            startTimer()
        }
        .onDisappear { gameTimer?.invalidate() }
    }

    private var timeText: String {
        "\(remaining / 60):\(String(format: "%02d", remaining % 60))"
    }

    private func moveTarget() {
        guard !isFinished else { return }
        score += 1
        target = randomTarget
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !isFinished else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                }
                if remainingSeconds == 0 {
                    isFinished = true
                    gameTimer?.invalidate()
                }
            }
        }
    }

    private var randomTarget: UnitPoint {
        UnitPoint(
            x: CGFloat.random(in: 0.16...0.84),
            y: CGFloat.random(in: 0.16...0.84)
        )
    }
}
