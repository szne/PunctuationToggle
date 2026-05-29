import Foundation
import AppKit

final class UpdateChecker {
    private static let releaseAPIURL = URL(
        string: "https://api.github.com/repos/szne/PunctuationToggle/releases/latest"
    )!

    /// - Parameter silentIfLatest: true = 最新版のときは何も表示しない（起動時チェック用）
    static func checkForUpdates(silentIfLatest: Bool) {
        var request = URLRequest(url: releaseAPIURL)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let tagName = json["tag_name"] as? String
            else { return }

            let latestVersion  = tagName.drop(while: { $0 == "v" }).description
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                                     as? String ?? "0"

            DispatchQueue.main.async {
                if isNewer(latestVersion, than: currentVersion) {
                    showUpdateAvailable(tag: tagName,
                                       htmlURL: json["html_url"] as? String)
                } else if !silentIfLatest {
                    showAlreadyLatest(version: currentVersion)
                }
            }
        }.resume()
    }

    // MARK: - Private

    /// セマンティックバージョン比較（例: "1.1.0" > "1.0.0"）
    private static func isNewer(_ latest: String, than current: String) -> Bool {
        latest.compare(current, options: .numeric) == .orderedDescending
    }

    private static func showUpdateAvailable(tag: String, htmlURL: String?) {
        let alert = NSAlert()
        alert.messageText = "アップデートがあります"
        alert.informativeText = "新しいバージョン \(tag) が公開されています。"
        alert.addButton(withTitle: "ダウンロードページを開く")
        alert.addButton(withTitle: "後で")
        alert.alertStyle = .informational

        if alert.runModal() == .alertFirstButtonReturn,
           let urlStr = htmlURL,
           let url = URL(string: urlStr) {
            NSWorkspace.shared.open(url)
        }
    }

    private static func showAlreadyLatest(version: String) {
        let alert = NSAlert()
        alert.messageText = "最新バージョンです"
        alert.informativeText = "現在のバージョン \(version) は最新です。"
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.runModal()
    }
}
