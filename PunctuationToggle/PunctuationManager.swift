import Foundation
import Combine

final class PunctuationManager: ObservableObject {
    private static let udCurrentMode  = "currentMode"
    private static let udEnabledModes = "enabledModes"
    private static let kotoeriDomain  = "com.apple.inputmethod.Kotoeri"
    private static let kotoeriKey     = "JIMPrefPunctuationTypeKey"

    /// 現在アクティブなモード値（0–3）
    @Published private(set) var currentMode: Int

    /// トグル対象として有効なモード値の配列
    @Published var enabledModes: [Int]

    var currentLabel: String {
        PunctuationMode(rawValue: currentMode)?.displayLabel ?? "？"
    }

    init() {
        // 旧 isWabunMode キーからのマイグレーション
        if let saved = UserDefaults.standard.object(forKey: Self.udCurrentMode) as? Int {
            currentMode = saved
        } else if let wasWabun = UserDefaults.standard.object(forKey: "isWabunMode") as? Bool {
            currentMode = wasWabun ? 0 : 3
        } else {
            currentMode = 0
        }

        enabledModes = UserDefaults.standard.array(forKey: Self.udEnabledModes) as? [Int] ?? [0, 3]
    }

    /// 有効モードを順番にサイクルする（左クリック）
    func toggle() {
        let sorted = enabledModes.sorted()
        guard sorted.count >= 1 else { return }
        let idx = sorted.firstIndex(of: currentMode) ?? -1
        currentMode = sorted[(idx + 1) % sorted.count]
        persistCurrentMode()
        applyToKotoeri()
    }

    /// 設定画面からモードの有効/無効を変更する
    func setMode(_ mode: PunctuationMode, enabled: Bool) {
        var modes = enabledModes
        if enabled {
            if !modes.contains(mode.rawValue) { modes.append(mode.rawValue) }
        } else {
            guard modes.count > 2 else { return }   // 最低 2 つは必須
            modes.removeAll { $0 == mode.rawValue }
        }
        enabledModes = modes
        UserDefaults.standard.set(enabledModes, forKey: Self.udEnabledModes)

        // 現在のモードが無効化された場合は先頭モードへ
        if !enabledModes.contains(currentMode) {
            currentMode = enabledModes.sorted().first ?? 0
            persistCurrentMode()
            applyToKotoeri()
        }
    }

    // MARK: - Private

    private func persistCurrentMode() {
        UserDefaults.standard.set(currentMode, forKey: Self.udCurrentMode)
    }

    private func applyToKotoeri() {
        // JIMPrefPunctuationTypeKey はビットマスク: 0=、。 1=，。 2=、． 3=，．
        shell("/usr/bin/defaults",
              "write", Self.kotoeriDomain, Self.kotoeriKey, "-int", "\(currentMode)")
        // macOS 13+ のプロセス名は JapaneseIM-RomajiTyping / JapaneseIM-KanaTyping
        shell("/usr/bin/killall", "-HUP", "-m", "JapaneseIM.*")
    }

    private func shell(_ path: String, _ args: String...) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        try? p.run()
        p.waitUntilExit()
    }
}
