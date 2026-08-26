import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step = 0
    @State private var cigarettesPerDay = 10
    @State private var packPrice = 20.0
    @State private var cigarettesPerPack = 20
    @State private var smokingYears = 5
    @State private var tarMilligrams = 10.0
    @State private var quitDate = Date()
    @State private var scenes = ""

    private let totalSteps = 7

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                onboardingHeader

                TabView(selection: $step) {
                    dailyCigarettesStep.tag(0)
                    packPriceStep.tag(1)
                    packSizeStep.tag(2)
                    smokingYearsStep.tag(3)
                    tarStep.tag(4)
                    quitDateStep.tag(5)
                    riskScenesStep.tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.snappy, value: step)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button(action: advance) {
                Text(step == totalSteps - 1 ? "开始戒烟" : "继续")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .liquidGlassProminentButton()
            .tint(.green)
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.ultraThinMaterial)
        }
    }

    private var onboardingHeader: some View {
        HStack(spacing: 16) {
            Button {
                guard step > 0 else { return }
                step -= 1
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline.weight(.bold))
                    .frame(width: 44, height: 44)
                    .background(.thinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .opacity(step == 0 ? 0 : 1)
            .accessibilityLabel("上一步")

            ProgressView(value: Double(step + 1), total: Double(totalSteps))
                .tint(.green)
                .accessibilityLabel("填写进度")
                .accessibilityValue("第 \(step + 1) 项，共 \(totalSteps) 项")
        }
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var dailyCigarettesStep: some View {
        OnboardingStep(icon: "lungs.fill", title: "你每天大约抽几根？", detail: "不用非常精确，按你平时的平均数量填写即可。") {
            OnboardingValueControl(value: "\(cigarettesPerDay)", unit: "根 / 天", decrement: {
                cigarettesPerDay = max(1, cigarettesPerDay - 1)
            }, increment: {
                cigarettesPerDay = min(100, cigarettesPerDay + 1)
            })
        }
    }

    private var packPriceStep: some View {
        OnboardingStep(icon: "yensign.circle.fill", title: "你常买的烟多少钱一包？", detail: "用于计算每一次忍住帮你节省的金额。") {
            OnboardingValueControl(value: packPrice.formatted(.currency(code: "CNY").precision(.fractionLength(0))), unit: "每包", decrement: {
                packPrice = max(1, packPrice - 1)
            }, increment: {
                packPrice = min(1_000, packPrice + 1)
            })
        }
    }

    private var packSizeStep: some View {
        OnboardingStep(icon: "shippingbox.fill", title: "每包有多少根？", detail: "大多数香烟为 20 根；这个数值会和价格一起计算节省金额。") {
            OnboardingValueControl(value: "\(cigarettesPerPack)", unit: "根 / 包", decrement: {
                cigarettesPerPack = max(1, cigarettesPerPack - 1)
            }, increment: {
                cigarettesPerPack = min(50, cigarettesPerPack + 1)
            })
        }
    }

    private var smokingYearsStep: some View {
        OnboardingStep(icon: "calendar", title: "你抽烟多久了？", detail: "请填写累计烟龄，中间戒烟的时间可以不计入。") {
            OnboardingValueControl(value: smokingYears.formatted(.number.precision(.fractionLength(0))), unit: "年", decrement: {
                smokingYears = max(0, smokingYears - 1)
            }, increment: {
                smokingYears = min(80, smokingYears + 1)
            })
        }
    }

    private var tarStep: some View {
        OnboardingStep(icon: "aqi.medium", title: "每支焦油含量是多少？", detail: "可查看烟盒标注；不确定时保留默认值 10 mg 即可。") {
            OnboardingValueControl(value: tarMilligrams.formatted(.number.precision(.fractionLength(1))), unit: "mg / 支", decrement: {
                tarMilligrams = max(0, tarMilligrams - 0.5)
            }, increment: {
                tarMilligrams = min(30, tarMilligrams + 0.5)
            })
        }
    }

    private var quitDateStep: some View {
        OnboardingStep(icon: "flag.checkered", title: "从什么时候开始戒烟？", detail: "可以选择现在，也可以补记你的戒烟开始时间。") {
            DatePicker("戒烟开始时间", selection: $quitDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.graphical)
                .tint(.green)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 24)
        }
    }

    private var riskScenesStep: some View {
        OnboardingStep(icon: "exclamationmark.shield.fill", title: "什么时候最容易想抽烟？", detail: "可选。记录常见场景后，戒刻会在高风险时间提前提醒你。") {
            TextField("例如：饭后、工作压力、喝酒、社交", text: $scenes, axis: .vertical)
                .lineLimit(3...5)
                .padding(18)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 28)
                .multilineTextAlignment(.leading)
        }
    }

    private func advance() {
        if step < totalSteps - 1 {
            step += 1
        } else {
            modelContext.insert(QuitProfile(
                cigarettesPerDay: cigarettesPerDay,
                packPrice: packPrice,
                cigarettesPerPack: cigarettesPerPack,
                smokingYears: smokingYears,
                tarMilligramsPerCigarette: tarMilligrams,
                quitDate: quitDate,
                highRiskScenes: scenes
            ))
        }
    }
}

private struct OnboardingStep<Content: View>: View {
    let icon: String
    let title: String
    let detail: String
    let content: Content

    init(icon: String, title: String, detail: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 28)
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 72, weight: .medium))
                .foregroundStyle(.green)
                .frame(height: 130)
            Text(title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 36)
            Text(detail)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 18)
                .padding(.horizontal, 38)
            Spacer(minLength: 38)
            content
            Spacer(minLength: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct OnboardingValueControl: View {
    let value: String
    let unit: String
    let decrement: () -> Void
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 42) {
            Button(action: decrement) { Image(systemName: "minus") }
                .accessibilityLabel("减少")
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
                    .minimumScaleFactor(0.6)
                Text(unit).font(.title3.weight(.semibold)).foregroundStyle(.secondary)
            }
            .frame(minWidth: 150)
            Button(action: increment) { Image(systemName: "plus") }
                .accessibilityLabel("增加")
        }
        .font(.title2.weight(.bold))
        .buttonStyle(OnboardingRoundButtonStyle())
    }
}

private struct OnboardingRoundButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 62, height: 62)
            .background(Color.green.opacity(configuration.isPressed ? 0.65 : 0.82), in: Circle())
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
    }
}
