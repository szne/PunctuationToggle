import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @ObservedObject var manager: PunctuationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: モード選択
            Text("トグルするモードを選択")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(PunctuationMode.allCases) { mode in
                    Toggle(isOn: binding(for: mode)) {
                        HStack(spacing: 10) {
                            Text(mode.displayLabel)
                                .font(.system(size: 15, design: .monospaced))
                                .frame(width: 36, alignment: .leading)
                            Text(mode.detail)
                                .font(.system(size: 13))
                        }
                    }
                    .toggleStyle(.checkbox)
                    .disabled(isDisabled(mode))
                }
            }

            Divider()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("切替順：")
                    .foregroundColor(.secondary)
                Text(cycleOrder)
                    .font(.system(.body, design: .monospaced))
            }
            .font(.system(size: 12))

            if manager.enabledModes.count < 2 {
                Label("2 つ以上選択してください", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Divider()

            // MARK: ログイン時起動
            Toggle("ログイン時に自動起動", isOn: launchAtLoginBinding)
                .toggleStyle(.checkbox)

        }
        .padding(20)
        .frame(width: 320)
    }

    // MARK: - Bindings

    private func binding(for mode: PunctuationMode) -> Binding<Bool> {
        Binding(
            get: { manager.enabledModes.contains(mode.rawValue) },
            set: { manager.setMode(mode, enabled: $0) }
        )
    }

    /// ログイン時起動の Binding（SMAppService で読み書き）
    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: {
                SMAppService.mainApp.status == .enabled
            },
            set: { enable in
                do {
                    if enable {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Launch at login error: \(error.localizedDescription)")
                }
            }
        )
    }

    // MARK: - Helpers

    /// 有効なモードが 2 つしかない場合、チェック済みのものは外せないようにする
    private func isDisabled(_ mode: PunctuationMode) -> Bool {
        manager.enabledModes.contains(mode.rawValue) && manager.enabledModes.count <= 2
    }

    private var cycleOrder: String {
        let labels = manager.enabledModes.sorted()
            .compactMap { PunctuationMode(rawValue: $0)?.displayLabel }
        guard !labels.isEmpty else { return "（未選択）" }
        return labels.joined(separator: " → ") + " → …"
    }
}
