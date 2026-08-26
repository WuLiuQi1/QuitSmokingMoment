import SwiftUI

struct QuitSmokingEducationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                ForEach(QuitEducationArticle.allCases) { article in
                    NavigationLink {
                        QuitSmokingEducationDetailView(article: article)
                    } label: {
                        EducationSection(article: article, showsDisclosure: true)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("打开\(article.title)详情")
                }
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

private enum QuitEducationArticle: String, CaseIterable, Identifiable {
    case harms, science, craving, lapse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .harms: return "吸烟的危害"
        case .science: return "怎样科学戒烟"
        case .craving: return "烟瘾来了怎么办"
        case .lapse: return "复吸后如何继续"
        }
    }

    var symbol: String {
        switch self {
        case .harms: return "lungs.fill"
        case .science: return "checklist"
        case .craving: return "shield.lefthalf.filled"
        case .lapse: return "arrow.uturn.backward.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .harms: return .orange
        case .science: return .blue
        case .craving: return .mint
        case .lapse: return .red
        }
    }

    var summary: String {
        switch self {
        case .harms: return "了解风险，不是制造恐惧，而是让每一次选择更有理由。"
        case .science: return "戒烟是一个过程；支持、计划和工具比单独硬扛更可靠。"
        case .craving: return "先给自己几分钟。烟瘾会来，也会过去。"
        case .lapse: return "复吸不是清零，而是一次了解自己的机会。"
        }
    }

    var previewPoints: [String] { Array(detailSections.flatMap { $0.points }.prefix(3)) }

    var detailSections: [EducationDetailSection] {
        switch self {
        case .harms:
            [
                EducationDetailSection("身体会受到哪些影响", ["烟草烟雾含有多种有害化学物质，吸烟会损害心血管和呼吸系统。", "吸烟与多种癌症风险增加有关，也会影响身边人免受二手烟危害的机会。"]),
                EducationDetailSection("现在开始仍然有意义", ["戒烟不是只有长期坚持才有价值；从停止吸烟开始，身体就会逐步恢复。", "不必等到“准备得完美”才行动，今天少抽或不抽都是向前的一步。"]),
                EducationDetailSection("可以立刻做的事", ["写下你最在意的戒烟理由，例如家人、体力、睡眠或省下的钱。", "把烟、打火机和烟灰缸移出触手可及的地方，减少自动点烟的机会。"])
            ]
        case .science:
            [
                EducationDetailSection("先做一个可执行的计划", ["设定一个戒烟开始时间，并提前告诉愿意支持你的人。", "把饭后、喝酒、压力大、社交等容易想抽烟的场景写下来。"]),
                EducationDetailSection("为诱因准备替代动作", ["饭后刷牙或散步；压力大时做几轮慢呼吸；社交时准备无糖口香糖或饮料。", "在戒刻记录诱因、心情和强度，找出最需要提前准备的时段。"]),
                EducationDetailSection("善用专业支持", ["行为支持、戒烟咨询与合适的治疗方法可以提高成功机会。", "如需药物或有基础疾病、孕期、正在用药，请咨询医生、戒烟门诊或药师。"])
            ]
        case .craving:
            [
                EducationDetailSection("先延迟，不急着决定", ["告诉自己先等 3–5 分钟，不必承诺永远不抽，只处理眼前这一阵。", "烟瘾常会随着时间起伏，给自己空间后可能开始减弱。"]),
                EducationDetailSection("把注意力交给身体", ["慢慢吸气、停一停、再更慢地呼气；重复几轮。", "喝一杯水、走动几分钟、嚼无糖口香糖，或联系一个支持你的人。"]),
                EducationDetailSection("把这次变成下一次的准备", ["在急救页面选择诱因和心情，并记录当前强度。", "忍住后记一次成功；即使抽了，也如实记录，不用责备自己。"])
            ]
        case .lapse:
            [
                EducationDetailSection("先记录事实，不评价自己", ["记录抽了多少支、当时的诱因、心情和地点。", "一次复吸不等于之前的努力消失，也不必因此放弃整个计划。"]),
                EducationDetailSection("找出下一次的分叉点", ["回想：我是在什么场景、什么情绪下开始想抽？", "为同类场景准备一个更小的替代动作，例如先喝水、离开现场或发消息求助。"]),
                EducationDetailSection("立刻回到计划", ["把剩下的烟和相关物品移开，重新选择下一次不抽。", "如果反复复吸或烟瘾很强，尽早向医生、戒烟门诊或药师寻求支持。"])
            ]
        }
    }
}

private struct EducationDetailSection: Identifiable {
    let title: String
    let points: [String]
    var id: String { title }

    init(_ title: String, _ points: [String]) {
        self.title = title
        self.points = points
    }
}

private struct EducationSection: View {
    let article: QuitEducationArticle
    var showsDisclosure = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(article.title, systemImage: article.symbol)
                    .font(.headline)
                    .foregroundStyle(article.tint)
                Spacer()
                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            Text(article.summary)
                .font(.subheadline.weight(.medium))
            VStack(alignment: .leading, spacing: 9) {
                ForEach(article.previewPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(article.tint)
                        Text(point)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .liquidGlassCard(tint: article.tint.opacity(0.10), cornerRadius: 20)
    }
}

private struct QuitSmokingEducationDetailView: View {
    let article: QuitEducationArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label(article.title, systemImage: article.symbol)
                        .font(.headline)
                        .foregroundStyle(article.tint)
                    Text(article.summary)
                        .font(.title3.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .liquidGlassCard(tint: article.tint.opacity(0.12), cornerRadius: 22)

                ForEach(article.detailSections) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.title)
                            .font(.headline)
                        ForEach(section.points, id: \.self) { point in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(article.tint)
                                Text(point)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .liquidGlassCard(tint: article.tint.opacity(0.08), cornerRadius: 20)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("信息来源与提示")
                        .font(.headline)
                    Link("世界卫生组织：戒烟支持", destination: URL(string: "https://www.who.int/teams/health-promotion/tobacco-control/quitting")!)
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
            .padding()
        }
        .background(LiquidGlassBackdrop())
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
