//
//  ContentView.swift
//  OWUI
//
//  Created by Ben Smith on 28/06/2025.
//

import SwiftUI
import SwiftData
import WebKit
import AppKit

struct WebView: NSViewRepresentable {
    let url: URL
    
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var urlInput: String = ""
    
    

    // Get owuiURL from the saved data in userdefaults
    private let owuiURL = UserDefaults.standard.string(forKey: "owuiURL") ?? "pineapple"

    var body: some View {
        if owuiURL == "pineapple" || owuiURL == "https://example.com" {
            VStack {
                // Input box for the OWUI URL
                TextField("http://localhost:8080", text: $urlInput)
                    .frame(maxWidth: 300)
                
                Button("Set URL") {
                    UserDefaults.standard.set(urlInput, forKey: "owuiURL")
                }
                
            } .frame(minWidth: 600, minHeight: 300)
        } else {
        VStack {
            if let url = URL(string: owuiURL) {
                WebView(url: url)
                    .frame(minWidth: 600, minHeight: 300)
            } else {
                Text("Invalid URL")
            }
        }}
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
