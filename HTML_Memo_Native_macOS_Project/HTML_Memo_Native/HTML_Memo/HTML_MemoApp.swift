import Cocoa
import WebKit
import UniformTypeIdentifiers

@main
final class HTMLMemoApp: NSObject, NSApplicationDelegate, WKScriptMessageHandler, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        controller.add(self, name: "native")
        config.userContentController = controller
        config.preferences.setValue(true, forKey: "developerExtrasEnabled")

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsMagnification = true

        let contentURL = Bundle.main.url(forResource: "HTML_Memo", withExtension: "html")!
        webView.loadFileURL(contentURL, allowingReadAccessTo: contentURL.deletingLastPathComponent())

        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1100, height: 800),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered,
                          defer: false)
        window.title = "HTML Memo"
        window.minSize = NSSize(width: 700, height: 500)
        window.contentView = webView
        window.center()
        window.makeKeyAndOrderFront(nil)

        buildMenu()
        NSApp.activate(ignoringOtherApps: true)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        do {
            let data = try Data(contentsOf: url)
            let html = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            callJS("window.__nativeOpen(\(jsString(html)), \(jsString(url.lastPathComponent)))")
        } catch {
            showError(error)
        }
    }

    func buildMenu() {
        let main = NSMenu()
        let appItem = NSMenuItem()
        main.addItem(appItem)
        let appMenu = NSMenu()
        appItem.submenu = appMenu
        appMenu.addItem(withTitle: "HTML Memo 종료", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let fileItem = NSMenuItem(title: "파일", action: nil, keyEquivalent: "")
        main.addItem(fileItem)
        let fileMenu = NSMenu(title: "파일")
        fileItem.submenu = fileMenu
        fileMenu.addItem(withTitle: "열기…", action: #selector(openDocument), keyEquivalent: "o").target = self
        fileMenu.addItem(withTitle: "저장", action: #selector(saveDocument), keyEquivalent: "s").target = self
        fileMenu.addItem(withTitle: "다른 이름으로 저장…", action: #selector(saveDocumentAs), keyEquivalent: "S").target = self
        fileMenu.addItem(NSMenuItem.separator())
        fileMenu.addItem(withTitle: "닫기", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")

        let editItem = NSMenuItem(title: "편집", action: nil, keyEquivalent: "")
        main.addItem(editItem)
        let editMenu = NSMenu(title: "편집")
        editItem.submenu = editMenu
        editMenu.addItem(withTitle: "실행 취소", action: #selector(undo), keyEquivalent: "z").target = self
        editMenu.addItem(withTitle: "다시 실행", action: #selector(redo), keyEquivalent: "Z").target = self
        editMenu.addItem(NSMenuItem.separator())
        editMenu.addItem(withTitle: "잘라내기", action: #selector(cut), keyEquivalent: "x").target = self
        editMenu.addItem(withTitle: "복사", action: #selector(copy), keyEquivalent: "c").target = self
        editMenu.addItem(withTitle: "붙여넣기", action: #selector(paste), keyEquivalent: "v").target = self
        editMenu.addItem(withTitle: "전체 선택", action: #selector(selectAll), keyEquivalent: "a").target = self

        NSApp.mainMenu = main
    }

    @objc func openDocument() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.html, .plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let data = try Data(contentsOf: url)
            let html = String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
            let filename = url.lastPathComponent
            callJS("window.__nativeOpen(\(jsString(html)), \(jsString(filename)))")
        } catch {
            showError(error)
        }
    }

    @objc func saveDocument() {
        callJS("window.__nativeSave()")
    }

    @objc func saveDocumentAs() {
        callJS("window.__nativeSaveAs()")
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "native", let body = message.body as? [String: Any], let action = body["action"] as? String else { return }
        switch action {
        case "open":
            openDocument()
        case "save":
            let html = body["html"] as? String ?? ""
            let filename = body["filename"] as? String ?? "Memo.html"
            writeDocument(html: html, suggestedName: filename, forcePanel: false)
        case "saveAs":
            let html = body["html"] as? String ?? ""
            let filename = body["filename"] as? String ?? "Memo.html"
            writeDocument(html: html, suggestedName: filename, forcePanel: true)
        default:
            break
        }
    }

    private func writeDocument(html: String, suggestedName: String, forcePanel: Bool) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedName.hasSuffix(".html") ? suggestedName : suggestedName + ".html"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try Data(html.utf8).write(to: url, options: .atomic)
            callJS("window.__nativeSaved(\(jsString(url.lastPathComponent)))")
        } catch {
            showError(error)
        }
    }

    private func callJS(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: nil)
    }

    private func jsString(_ value: String) -> String {
        let data = try! JSONSerialization.data(withJSONObject: [value], options: [])
        let array = String(data: data, encoding: .utf8)!
        return String(array.dropFirst().dropLast())
    }

    private func showError(_ error: Error) {
        let alert = NSAlert(error: error)
        alert.runModal()
    }

    @objc func undo() { webView.undoManager?.undo() }
    @objc func redo() { webView.undoManager?.redo() }
    @objc func cut() { webView.cut(nil) }
    @objc func copy() { webView.copy(nil) }
    @objc func paste() { webView.paste(nil) }
    @objc func selectAll() { webView.selectAll(nil) }
}
