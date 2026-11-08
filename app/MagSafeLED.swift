import AppKit

let modeFile = URL(fileURLWithPath: "/Users/Shared/MagSafeLED/mode")
let modes: [(id: String, title: String, symbol: String)] = [
    ("off", "Apagada", "bolt.slash"),
    ("system", "Padrão do sistema", "bolt"),
    ("green", "Sempre verde", "bolt.fill"),
    ("orange", "Sempre laranja", "bolt.fill"),
]

final class App: NSObject, NSApplicationDelegate {
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    var current: String {
        (try? String(contentsOf: modeFile, encoding: .utf8))?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "system"
    }

    func applicationDidFinishLaunching(_ n: Notification) { refresh() }

    func refresh() {
        let mode = modes.first { $0.id == current } ?? modes[1]
        item.button?.image = NSImage(systemSymbolName: mode.symbol, accessibilityDescription: mode.title)

        let menu = NSMenu()
        menu.addItem(withTitle: "Luz do MagSafe", action: nil, keyEquivalent: "")
        menu.addItem(.separator())
        for m in modes {
            let mi = NSMenuItem(title: m.title, action: #selector(pick(_:)), keyEquivalent: "")
            mi.representedObject = m.id
            mi.state = m.id == mode.id ? .on : .off
            mi.target = self
            menu.addItem(mi)
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Sair", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
    }

    @objc func pick(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        do {
            try id.write(to: modeFile, atomically: false, encoding: .utf8)
        } catch {
            let alert = NSAlert()
            alert.messageText = "Não consegui salvar. Rode o install.sh primeiro."
            alert.runModal()
        }
        refresh()
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
