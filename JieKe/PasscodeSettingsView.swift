import CryptoKit
import SwiftUI

struct PasscodeSettingsView: View {
    @AppStorage("privacyPasscodeHash") private var storedHash = ""
    @State private var passcode = ""
    @State private var confirmation = ""
    @State private var message = ""

    var body: some View {
        Form {
            Section("独立密码") {
                SecureField("输入 4–12 位密码", text: $passcode)
                    .keyboardType(.numberPad)
                SecureField("再次输入密码", text: $confirmation)
                    .keyboardType(.numberPad)
                Button("保存密码") { save() }
                    .disabled(passcode.count < 4 || passcode != confirmation)
                if !storedHash.isEmpty {
                    Button("移除独立密码", role: .destructive) {
                        storedHash = ""
                        passcode = ""
                        confirmation = ""
                        message = "已移除独立密码。"
                    }
                }
            }
            Section {
                Text("独立密码保存在此设备中，并以不可逆摘要形式存储。它可以作为 Face ID 或设备密码不可用时的备用解锁方式。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if !message.isEmpty {
                Section { Text(message).foregroundStyle(.green) }
            }
        }
        .navigationTitle("独立密码")
    }

    private func save() {
        guard passcode == confirmation, (4...12).contains(passcode.count) else { return }
        storedHash = PasscodeHasher.hash(passcode)
        passcode = ""
        confirmation = ""
        message = "独立密码已保存。"
    }
}

enum PasscodeHasher {
    static func hash(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).compactMap { String(format: "%02x", $0) }.joined()
    }
}
