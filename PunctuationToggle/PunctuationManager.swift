import Foundation

final class PunctuationManager {
    private static let udKey = "isWabunMode"
    private static let kotoeriDomain = "com.apple.inputmethod.Kotoeri"
    private static let kotoeriKey = "JIMPrefPunctuationTypeKey"

    private(set) var isWabunMode: Bool {
        didSet { UserDefaults.standard.set(isWabunMode, forKey: Self.udKey) }
    }

    /// 現在のモードのラベル（メニューバー表示用）
    var label: String { isWabunMode ? "、。" : "，．" }
    /// 切り替え後のラベル
    var nextLabel: String { isWabunMode ? "，．" : "、。" }

    init() {
        if UserDefaults.standard.object(forKey: Self.udKey) != nil {
            isWabunMode = UserDefaults.standard.bool(forKey: Self.udKey)
        } else {
            isWabunMode = true  // デフォルト: 和文（、。）
        }
    }

    func toggle() {
        isWabunMode.toggle()
        applyToKotoeri()
    }

    private func applyToKotoeri() {
        // JIMPrefPunctuationTypeKey はビットマスク:
        //   bit0 = comma  (0=、 1=，)
        //   bit1 = period (0=。 1=．)
        //   0 = 、。 / 3 = ，．
        let value = isWabunMode ? "0" : "3"
        shell("/usr/bin/defaults",
              "write", Self.kotoeriDomain, Self.kotoeriKey, "-int", value)
        // macOS 13+ ではプロセス名が JapaneseIM-RomajiTyping / JapaneseIM-KanaTyping
        // -m フラグで正規表現マッチ（どちらの入力方式でも対応）
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
