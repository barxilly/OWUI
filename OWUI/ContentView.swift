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
  
  var body: some View {
    VStack {
      if owuiURL == "pineapple" || owuiURL == "https://example.com" {
        VStack {
          TextField("http://localhost:8080", text: $urlInput)
            .frame(maxWidth: 300)

          Button("Set URL") {
            UserDefaults.standard.set(urlInput, forKey: "owuiURL")
            owuiURL = urlInput
            // Reload the view to reflect the new URL
              if let url = URL(string: urlInput) {
                WebView(url: url, pageTitle: $pageTitle)
                  .frame(minWidth: 600, minHeight: 300)
              } else {
                print("Invalid URL")
              }
          }

        }.frame(minWidth: 600, minHeight: 300)
      } else {
        VStack {
          if let url = URL(string: owuiURL) {
            WebView(url: url, pageTitle: $pageTitle)
              .frame(minWidth: 600, minHeight: 300)
          } else {
            Text("Invalid URL")
          }
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetURL"))) { _ in
      owuiURL = "pineapple"
      urlInput = ""
    }
    .onChange(of: pageTitle) { _, newTitle in
      if let window = NSApplication.shared.windows.first {
        window.title = newTitle
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
