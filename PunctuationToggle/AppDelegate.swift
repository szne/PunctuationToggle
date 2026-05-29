import AppKit
import Combine
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let manager = PunctuationManager()
    private var cancellable: AnyCancellable?
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }
        button.title = manager.currentLabel
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.target = self

        // currentMode が変わるたびにメニューバーのラベルを更新
        cancellable = manager.$currentMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.statusItem?.button?.title = self?.manager.currentLabel ?? ""
            }
    }

    // MARK: - Click handling

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            manager.toggle()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        let infoItem = NSMenuItem(
            title: "現在: \(manager.currentLabel)",
            action: nil,
            keyEquivalent: ""
        )
        infoItem.isEnabled = false
        menu.addItem(infoItem)

        menu.addItem(.separator())

        let toggleItem = NSMenuItem(
            title: "切り替え",
            action: #selector(toggleFromMenu),
            keyEquivalent: "t"
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(
            title: "設定...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "終了",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        // 一時的にメニューを紐付けて表示し、左クリック挙動を維持するため直後に解除
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    // MARK: - Actions

    @objc private func toggleFromMenu() {
        manager.toggle()
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let view = SettingsView(manager: manager)
            let vc = NSHostingController(rootView: view)
            let win = NSWindow(contentViewController: vc)
            win.title = "句読点設定"
            win.styleMask = [.titled, .closable]
            win.isReleasedWhenClosed = false
            settingsWindow = win
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
