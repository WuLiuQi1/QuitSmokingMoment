import SwiftUI
import UIKit

struct FocusGameView: View {
    @Environment(\.dismiss) private var dismiss
    let onCompleted: () -> Void

    @State private var remainingSeconds = 120
    @State private var gameTimer: Timer?
    @State private var driftTimer: Timer?
    @State private var score = 0
    @State private var streak = 0
    @State private var target = UnitPoint(x: 0.5, y: 0.5)
    @State private var pulse = false
    @State private var hitFlash = false
    @State private var isFinished = false

    private var remaining: Int { max(0, remainingSeconds) }
    private var encouragement: String {
        if isFinished { return "两分钟完成，你给自己留出了缓冲。" }
        if streak >= 6 { return "节奏真好，继续捕捉下一束光。" }
        if streak >= 3 { return "连击中，烟瘾正在慢慢过去。" }
        return "每捕捉一束光，都是一次少吸的选择。"
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 7) {
                Label("捕光挑战", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.indigo)
                Text(isFinished ? "你完成了两分钟的转移注意" : "跟着光点，把注意力留在当下")
                    .font(.title3.bold())
                Text(encouragement)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 12) {
                statLabel("已捕光", value: "\(score)", icon: "hand.tap.fill")
                Divider().frame(height: 30)
                statLabel("当前连击", value: "×\(streak)", icon: "bolt.fill")
                Spacer()
                Text(isFinished ? "完成" : timeText)
                    .monospacedDigit()
                    .font(.headline)
                    .foregroundStyle(isFinished ? .green : .indigo)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .liquidGlassCard(tint: .indigo.opacity(0.12), cornerRadius: 18)

            GeometryReader { proxy in
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(LinearGradient(colors: [.blue.opacity(0.16), .indigo.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(.blue.opacity(0.22), lineWidth: 1)

                    ForEach(0..<10, id: \.self) { index in
                        Circle()
                            .fill(.white.opacity(index.isMultiple(of: 2) ? 0.32 : 0.17))
                            .frame(width: CGFloat(5 + index % 3 * 3))
                            .position(
                                x: proxy.size.width * CGFloat((index * 37) % 92 + 4) / 100,
                                y: proxy.size.height * CGFloat((index * 23) % 84 + 8) / 100
                            )
                    }

                    if isFinished {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 58))
                                .foregroundStyle(.green)
                            Text("两分钟完成")
                                .font(.title2.bold())
                            Text("已捕捉 \(score) 束光，也给自己争取到一段缓冲。")
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        Button(action: captureLight) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.12))
                                    .frame(width: 106, height: 106)
                                    .scaleEffect(pulse ? 1.18 : 0.82)
                                Circle()
                                    .stroke(.white.opacity(0.7), lineWidth: 2)
                                    .frame(width: 80, height: 80)
                                Circle()
                                    .fill(RadialGradient(colors: [.white, .cyan, .blue], center: .topLeading, startRadius: 3, endRadius: 38))
                                    .frame(width: 62, height: 62)
                                Image(systemName: "sparkle")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(hitFlash ? 1.20 : 1)
                            .shadow(color: .blue.opacity(0.45), radius: 18, y: 7)
                        }
                        .buttonStyle(.plain)
                        .position(
                            x: max(58, min(proxy.size.width - 58, target.x * proxy.size.width)),
                            y: max(58, min(proxy.size.height - 58, target.y * proxy.size.height))
                        )
                        .animation(.spring(response: 0.36, dampingFraction: 0.72), value: target)
                        .accessibilityLabel("捕捉光点，点按一次")
                    }
                }
            }
            .frame(height: 330)
            .liquidGlassCard(tint: .blue.opacity(0.10), cornerRadius: 30)

            if isFinished {
                Button("回到急救页，记录少吸") { onCompleted() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
            } else {
                Text("光点会自己换位，不用追求分数；把这两分钟留给自己就好。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
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
            resetGame()
            startTimers()
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { pulse = true }
        }
        .onDisappear { stopTimers() }
    }

    private func statLabel(_ title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.monospacedDigit())
        }
    }

    private var timeText: String {
        "\(remaining / 60):\(String(format: "%02d", remaining % 60))"
    }

    private func captureLight() {
        guard !isFinished else { return }
        score += 1
        streak += 1
        withAnimation(.easeOut(duration: 0.12)) { hitFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.72)) {
                hitFlash = false
                target = randomTarget
            }
        }
        UIImpactFeedbackGenerator(style: streak.isMultiple(of: 5) ? .medium : .light).impactOccurred()
    }

    private func resetGame() {
        remainingSeconds = 120
        score = 0
        streak = 0
        isFinished = false
        pulse = false
        target = randomTarget
    }

    private func startTimers() {
        stopTimers()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !isFinished else { return }
                remainingSeconds -= 1
                if remainingSeconds <= 0 {
                    remainingSeconds = 0
                    isFinished = true
                    stopTimers()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
        driftTimer = Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            DispatchQueue.main.async {
                guard !isFinished else { return }
                streak = 0
                target = randomTarget
            }
        }
    }

    private func stopTimers() {
        gameTimer?.invalidate()
        driftTimer?.invalidate()
        gameTimer = nil
        driftTimer = nil
    }

    private var randomTarget: UnitPoint {
        UnitPoint(x: CGFloat.random(in: 0.16...0.84), y: CGFloat.random(in: 0.16...0.84))
    }
}
