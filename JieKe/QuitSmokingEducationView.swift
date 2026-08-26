import SwiftUI

struct QuitSmokingEducationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                EducationSection(
                    title: "吸烟的危害",
                    symbol: "lungs.fill",
                    tint: .orange,
                    summary: "了解风险，不是制造恐惧，而是让每一次选择更有理由。",
                    points: [
                        "烟草烟雾含有多种有害化学物质；吸烟会损害心血管和呼吸系统。",
                        "吸烟与多种癌症风险增加有关，也会影响身边人的健康。",
                        "无论烟龄长短，开始戒烟都可能带来健康益处。"
                    ]
                )
                EducationSection(
                    title: "怎样科学戒烟",
                    symbol: "checklist",
                    tint: .blue,
                    summary: "戒烟是一个过程；支持、计划和工具比单独硬扛更可靠。",
                    points: [
                        "设定戒烟日期，并提前处理烟、打火机和烟灰缸等线索。",
                        "记录饭后、喝酒、压力大、社交等诱因，为它们准备替代动作。",
                        "需要时咨询医生、戒烟门诊或药师；行为支持与适当治疗能提高成功机会。"
                    ]
                )
                EducationSection(
                    title: "烟瘾来了怎么办",
                    symbol: "shield.lefthalf.filled",
                    tint: .mint,
                    summary: "先给自己几分钟。烟瘾会来，也会过去。",
                    points: [
                        "延迟：先不抽，给自己 3–5 分钟。",
                        "呼吸：慢慢吸气、呼气，把注意力放回身体。",
                        "替代：喝水、走动、嚼无糖口香糖，或联系一个支持你的人。",
                        "记录：在戒刻里记下强度、诱因和心情，为下一次做好准备。"
                    ]
                )
                EducationSection(
                    title: "复吸后如何继续",
                    symbol: "arrow.uturn.backward.circle.fill",
                    tint: .red,
                    summary: "复吸不是清零，而是一次了解自己的机会。",
                    points: [
                        "如实记录抽了多少、当时的诱因和心情。",
                        "复盘：下次相同场景，我可以提前做什么？",
                        "不要因为一次复吸放弃原来的计划；从下一次选择重新开始。"
                    ]
                )
                professionalHelp
                sources
            }
            .padding()
        }
        .background(LiquidGlassBackdrop())
        .navigationTitle("戒烟科普")
        .navigationBarTitleDisplayMode(.large)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("戒烟知识库", systemImage: "book.closed.fill")
                .font(.headline)
                .foregroundStyle(.teal)
            Text("把每一次烟瘾，变成更了解自己的机会。")
                .font(.title2.bold())
            Text("这里提供健康教育信息，帮助你认识诱因、准备应对方法并坚持下去。")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: .teal.opacity(0.14), cornerRadius: 22)
    }

    private var professionalHelp: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("何时建议寻求专业帮助", systemImage: "stethoscope")
                .font(.headline)
                .foregroundStyle(.purple)
            Text("如果烟瘾很强、反复复吸，或正处于孕期、有心血管疾病、精神健康问题或正在用药，请优先咨询医生、戒烟门诊或药师。")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: .purple.opacity(0.12), cornerRadius: 20)
    }

    private var sources: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("信息来源")
                .font(.headline)
            Link("世界卫生组织：戒烟支持", destination: URL(string: "https://www.who.int/teams/health-promotion/tobacco-control/quitting")!)
            Link("世界卫生组织：成人烟草戒断临床指南", destination: URL(string: "https://www.who.int/news/item/02-07-2024-who-releases-first-ever-clinical-treatment-guideline-for-tobacco-cessation-in-adults")!)
            Link("CDC：戒烟建议", destination: URL(string: "https://www.cdc.gov/tobacco/campaign/tips/quit-smoking/tips-for-quitting/index.html")!)
            Text("本页为健康教育内容，不替代医生诊断、治疗或个体化用药建议。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

private struct EducationSection: View {
    let title: String
    let symbol: String
    let tint: Color
    let summary: String
    let points: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(.headline)
                .foregroundStyle(tint)
            Text(summary)
                .font(.subheadline.weight(.medium))
            VStack(alignment: .leading, spacing: 9) {
                ForEach(points, id: \.self) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(tint)
                        Text(point)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: tint.opacity(0.10), cornerRadius: 20)
    }
}
