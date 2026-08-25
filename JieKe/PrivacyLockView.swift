import LocalAuthentication
import SwiftUI

struct PrivacyProtectedView<Content: View>: View {
    @AppStorage("privacyLockEnabled") private var privacyLockEnabled = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isLocked = false
    @State private var isAuthenticating = false
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .blur(radius: isLocked ? 18 : 0)
                .allowsHitTesting(!isLocked)

            if isLocked {
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.tint)
                    Text("戒刻已锁定").font(.title2.bold())
                    Text("使用 Face ID 或设备密码继续")
                        .foregroundStyle(.secondary)
                    Button("解锁") { authenticate() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(36)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding()
            }
        }
        .onAppear { updateLockState() }
        .onChange(of: privacyLockEnabled) { _, _ in updateLockState() }
        .onChange(of: scenePhase) { _, phase in
            guard privacyLockEnabled else { return }
            if phase == .active, isLocked { authenticate() }
            if phase == .inactive || phase == .background { isLocked = true }
        }
    }

    private func updateLockState() {
        guard privacyLockEnabled else { isLocked = false; return }
        isLocked = true
        authenticate()
    }

    private func authenticate() {
        guard privacyLockEnabled, isLocked, !isAuthenticating else { return }
        isAuthenticating = true
        let context = LAContext()
        let reason = "解锁戒刻中的个人记录"
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) else {
            isAuthenticating = false
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
            DispatchQueue.main.async {
                isAuthenticating = false
                if success { isLocked = false }
            }
        }
    }
}
