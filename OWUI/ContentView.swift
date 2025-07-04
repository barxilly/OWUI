import AppKit
import SwiftData
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
  let url: URL
  @Binding var pageTitle: String

  func makeNSView(context: Context) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    let webView = WKWebView(frame: .zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    return webView
  }

  func updateNSView(_ webView: WKWebView, context: Context) {
    let request = URLRequest(url: url)
    webView.load(request)
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: WebView
    
    init(_ parent: WebView) {
      self.parent = parent
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      webView.evaluateJavaScript("document.title") { (result, error) in
        if let title = result as? String, !title.isEmpty {
          DispatchQueue.main.async {
            self.parent.pageTitle = title
          }
        }
      }
    }
  }
}
struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [Item]
  @State private var urlInput: String = ""
  @State private var owuiURL: String = UserDefaults.standard.string(forKey: "owuiURL") ?? "pineapple"
  @State private var pageTitle: String = "OWUI"
  @State private var webViewID = UUID()

  
  var body: some View {
    VStack {
      if owuiURL == "pineapple" || owuiURL == "pineappleE" || owuiURL == "https://example.com" {
        VStack {
          TextField("http://localhost:8080", text: $urlInput)
            .frame(maxWidth: 300)
            // Enter
            .onSubmit {
              // Check if the URL is valid and is OWUI (check for /static/splash.png existing on the server)
              let splashURLString = urlInput.hasSuffix("/") ? "\(urlInput)static/splash.png" : "\(urlInput)/static/splash.png"
              if let splashURL = URL(string: splashURLString) {
                let task = URLSession.shared.dataTask(with: splashURL) { data, response, error in
                  DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                      // splash.png exists, set the URL
                      UserDefaults.standard.set(urlInput, forKey: "owuiURL")
                      owuiURL = urlInput
                      webViewID = UUID() // Force reload
                    } else {
                      // splash.png does not exist, reset URL
                      UserDefaults.standard.removeObject(forKey: "owuiURL")
                      owuiURL = "pineappleE"
                      urlInput = ""
                    }
                  }
                }
                task.resume()
              } else {
                print("Invalid URL")
              }
            }
            
            Text(owuiURL == "pineappleE" ? "Please input a valid Open WebUI URL" : "")
              .foregroundColor(.red)
              .font(.caption)
              .padding(.top, 5)

          Button("Set URL") {
            // Check if the URL is valid and is OWUI (check for /static/splash.png existing on the server)
            let splashURLString = urlInput.hasSuffix("/") ? "\(urlInput)static/splash.png" : "\(urlInput)/static/splash.png"
            if let splashURL = URL(string: splashURLString) {
              let task = URLSession.shared.dataTask(with: splashURL) { data, response, error in
                DispatchQueue.main.async {
                  if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // splash.png exists, set the URL
                    UserDefaults.standard.set(urlInput, forKey: "owuiURL")
                    owuiURL = urlInput
                    webViewID = UUID() // Force reload
                  } else {
                    // splash.png does not exist, reset URL
                    UserDefaults.standard.removeObject(forKey: "owuiURL")
                    owuiURL = "pineappleE"
                    urlInput = ""
                  }
                }
              }
              task.resume()
            } else {
              print("Invalid URL")
            }
          }

        }.frame(minWidth: 600, minHeight: 300)
      } else {
        if let url = URL(string: owuiURL) {
          WebView(url: url, pageTitle: $pageTitle)
            .id(webViewID)
            .frame(minWidth: 600, minHeight: 300)
        } else {
          Text("Invalid URL")
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .navigation) {
        HStack {
          Button(action: {
            if let window = NSApplication.shared.windows.first,
               let webView = window.contentView?.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
              webView.goBack()
            }
          }) {
            Image(systemName: "chevron.left")
          }
          .help("Back")

          Button(action: {
            if let window = NSApplication.shared.windows.first,
               let webView = window.contentView?.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
              webView.goForward()
            }
          }) {
            Image(systemName: "chevron.right")
          }
          .help("Forward")

          Button(action: {
            if let window = NSApplication.shared.windows.first,
               let webView = window.contentView?.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
              webView.reload()
            }
          }) {
            Image(systemName: "arrow.clockwise")
          }
          .help("Refresh")
          
          if owuiURL != "pineapple" && owuiURL != "https://example.com" {
            Text(owuiURL)
              .foregroundColor(.secondary)
              .font(.caption)
              .lineLimit(1)
              .truncationMode(.middle)
              .padding(.trailing)
          }
        }
      }
      
      ToolbarItem(placement: .primaryAction) {
        HStack {
          Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ScreenshotPage"), object: nil)
          }) {
            Image(systemName: "camera")
          }
          .help("Screenshot")
          
          Button(action: {
            UserDefaults.standard.removeObject(forKey: "owuiURL")
            owuiURL = "pineapple"
            urlInput = ""
          }) {
            Image(systemName: "link")
          }
          .help("Reset URL")
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetURL"))) { _ in
      owuiURL = "pineapple"
      urlInput = ""
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScreenshotPage"))) { _ in
    if let window = NSApplication.shared.windows.first,
       let contentView = window.contentView {
      let rep = contentView.bitmapImageRepForCachingDisplay(in: contentView.bounds)!
      contentView.cacheDisplay(in: contentView.bounds, to: rep)
      let image = NSImage(size: contentView.bounds.size)
      image.addRepresentation(rep)
      let panel = NSSavePanel()
      panel.allowedContentTypes = [.png]
      panel.nameFieldStringValue = "screenshot.png"
      panel.begin { response in
        if response == .OK, let url = panel.url {
      if let tiffData = image.tiffRepresentation,
         let bitmap = NSBitmapImageRep(data: tiffData),
         let pngData = bitmap.representation(using: .png, properties: [:]) {
        try? pngData.write(to: url)
      }
        }
      }
    }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshPage"))) { _ in
      if let window = NSApplication.shared.windows.first,
         let webView = window.contentView?.subviews.first(where: { $0 is WKWebView }) as? WKWebView {
        webView.reload()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("HardRefreshPage"))) { _ in
      // Force WebView recreation by changing its ID
      webViewID = UUID()
    }
    .onChange(of: pageTitle) { _, newTitle in
      if let window = NSApplication.shared.windows.first {
        window.title = ""
      }
    }
  }
  private func addItem() {
    withAnimation {
      let newItem = Item(timestamp: Date())
      modelContext.insert(newItem)
    }
  }
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}
#Preview {
  ContentView()
    .modelContainer(for: Item.self, inMemory: true)
}
