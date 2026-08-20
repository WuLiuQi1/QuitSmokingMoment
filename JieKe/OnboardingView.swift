import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cigarettesPerDay = 10
    @State private var packPrice = 20.0
    @State private var cigarettesPerPack = 20
    @State private var smokingYears = 5
    @State private var quitDate = Date()
    @State private var scenes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "leaf.fill").font(.largeTitle).foregroundStyle(.green)
                        Text("从这一刻开始").font(.title.bold())
                        Text("戒刻会记录你的每一次坚持。资料只保存在本机。").foregroundStyle(.secondary)
                    }.padding(.vertical, 8)
                }
                Section("你的习惯") {
                    Stepper("每天约 \(cigarettesPerDay) 根", value: $cigarettesPerDay, in: 1...100)
                    Stepper("每包 \(cigarettesPerPack) 根", value: $cigarettesPerPack, in: 1...50)
                    Stepper("烟龄 \(smokingYears) 年", value: $smokingYears, in: 0...80)
                    HStack { Text("一包价格"); Spacer(); TextField("价格", value: $packPrice, format: .currency(code: "CNY")).multilineTextAlignment(.trailing).keyboardType(.decimalPad).frame(width: 120) }
                }
                Section("开始戒烟") {
                    DatePicker("开始时间", selection: $quitDate, displayedComponents: [.date, .hourAndMinute])
                    TextField("最容易想抽烟的场景（可选）", text: $scenes, axis: .vertical)
                }
                Section { Button("开始记录") { saveProfile() }.frame(maxWidth: .infinity).font(.headline) }
            }.navigationTitle("欢迎使用戒刻")
        }
    }

    private func saveProfile() {
        modelContext.insert(QuitProfile(cigarettesPerDay: cigarettesPerDay, packPrice: packPrice, cigarettesPerPack: cigarettesPerPack, smokingYears: smokingYears, quitDate: quitDate, highRiskScenes: scenes))
    }
}

