//
//  OWUIApp.swift
//  OWUI
//
//  Created by Ben Smith on 28/06/2025.
//

import SwiftUI
import SwiftData

@main
struct OWUIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .windowToolbarStyle(.unified)
        .commands {
            CommandMenu("OWUI URL") {
                Button("Reset URL") {
                    resetURL()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            CommandMenu("Page") {
                Button("Screenshot") {
                    screenshotPage()
                }
                .keyboardShortcut("s", modifiers: [.command, .option])
                Button("Refresh") {
                    refreshPage()
                }
                .keyboardShortcut("r", modifiers: [.command])
                Button("Hard Refresh") {
                    hardRefreshPage()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
    
    private func resetURL() {
        UserDefaults.standard.removeObject(forKey: "owuiURL")
        // Post a notification to tell ContentView to update
        NotificationCenter.default.post(name: NSNotification.Name("ResetURL"), object: nil)
    }

    private func screenshotPage() {
        NotificationCenter.default.post(name: NSNotification.Name("ScreenshotPage"), object: nil)
    }

    private func refreshPage() {
        NotificationCenter.default.post(name: NSNotification.Name("RefreshPage"), object: nil)
    }

    private func hardRefreshPage() {
        NotificationCenter.default.post(name: NSNotification.Name("HardRefreshPage"), object: nil)
    }
}
