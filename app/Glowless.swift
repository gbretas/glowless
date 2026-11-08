import AppKit
import Combine
import SwiftUI

let modeFile = URL(fileURLWithPath: "/Users/Shared/Glowless/mode")

struct Mode: Identifiable {
    let id, title, symbol: String
}

let modes = [
    Mode(id: "off", title: "Apagada", symbol: "bolt.slash"),
    Mode(id: "system", title: "Padrão do sistema", symbol: "bolt"),
    Mode(id: "green", title: "Sempre verde", symbol: "bolt.fill"),
    Mode(id: "orange", title: "Sempre laranja", symbol: "bolt.fill"),
]

final class Model: ObservableObject {
    @Published var mode = (try? String(contentsOf: modeFile, encoding: .utf8))?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? "system"

    var current: Mode { modes.first { $0.id == mode } ?? modes[1] }

    func set(_ id: String) {
        do {
            try id.write(to: modeFile, atomically: false, encoding: .utf8)
            mode = id
        } catch {
            let alert = NSAlert()
            alert.messageText = "Não consegui salvar. Rode o install.sh primeiro."
            alert.runModal()
        }
    }
}

struct SettingsView: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: model.current.symbol).font(.system(size: 30))
                VStack(alignment: .leading) {
                    Text("Glowless").font(.title2.bold())
                    Text("A luz do MagSafe do seu jeito").foregroundStyle(.secondary)
                }
            }
            Picker("", selection: Binding(get: { model.mode }, set: { model.set($0) })) {
                ForEach(modes) { Text($0.title).tag($0.id) }
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
            Text("Também fica na barra de menu. Se o ícone sumir, abra pelo Spotlight.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(width: 340)
    }
}

final class App: NSObject, NSApplicationDelegate {
    let model = Model()
    let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    var window: NSWindow?
    var sub: AnyCancellable?

    func applicationDidFinishLaunching(_ n: Notification) {
        sub = model.$mode.sink { [weak self] _ in DispatchQueue.main.async { self?.refreshMenu() } }
        // Login launches pass --background; opening from Spotlight/Finder shows the window.
        if !CommandLine.arguments.contains("--background") { showWindow() }
    }

    func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows: Bool) -> Bool {
        showWindow()
        return true
    }

    @objc func showWindow() {
        if window == nil {
            let w = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(model: model)))
            w.title = "Glowless"
            w.styleMask = [.titled, .closable]
            w.isReleasedWhenClosed = false
            w.center()
            window = w
        }
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func refreshMenu() {
        let current = model.current
        item.button?.image = NSImage(systemSymbolName: current.symbol, accessibilityDescription: current.title)

        let menu = NSMenu()
        for m in modes {
            let mi = NSMenuItem(title: m.title, action: #selector(pick(_:)), keyEquivalent: "")
            mi.representedObject = m.id
            mi.state = m.id == current.id ? .on : .off
            mi.target = self
            menu.addItem(mi)
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Abrir Glowless…", action: #selector(showWindow), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "Sair", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
    }

    @objc func pick(_ sender: NSMenuItem) {
        if let id = sender.representedObject as? String { model.set(id) }
    }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
