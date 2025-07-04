# OWUI - Open WebUI macOS Client

> [!NOTE]
> This README was generated with AI assistance to provide comprehensive documentation for the project.

A native macOS application that provides a dedicated wrapper for Open WebUI, built with SwiftUI and WebKit.

## Features

- **Native macOS Integration**: Built with SwiftUI for a seamless macOS experience
- **WebKit Integration**: Full-featured web browsing with navigation controls
- **Smart URL Validation**: Automatically validates Open WebUI instances by checking for `/static/splash.png`
- **Persistent Settings**: Remembers your Open WebUI URL across app launches
- **Navigation Controls**: Back, forward, and refresh functionality
- **Screenshot Capability**: Built-in screenshot functionality for web pages
- **Keyboard Shortcuts**: Quick access to common functions
- **Window Management**: Unified toolbar style with proper window controls

## Requirements

- macOS (compatible with SwiftUI and AppKit)
- Xcode (for building from source)
- Access to an Open WebUI instance

## Getting Started

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd OWUI
   ```

2. Open `OWUI.xcodeproj` in Xcode

3. Build and run the project (⌘R)

### First Launch

1. When you first launch OWUI, you'll see a URL input field
2. Enter your Open WebUI instance URL (e.g., `http://localhost:8080`)
3. Press Enter or click "Set URL" to connect
4. The app will validate the URL by checking for the Open WebUI splash image
5. Once validated, the web interface will load

## Usage

### URL Management

- **Setting URL**: Enter your Open WebUI URL in the input field and press Enter or click "Set URL"
- **URL Validation**: The app automatically validates that the URL points to a valid Open WebUI instance
- **Reset URL**: Use the reset button in the toolbar or the keyboard shortcut to change your URL

### Navigation

- **Back/Forward**: Use the navigation buttons in the toolbar
- **Refresh**: Standard refresh or hard refresh (recreates the WebView)
- **URL Display**: Current URL is shown in the toolbar when connected

### Screenshots

- Click the camera icon in the toolbar or use the keyboard shortcut
- Choose where to save your screenshot
- Screenshots capture the entire web content area

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Reset URL | ⌘⇧R |
| Screenshot | ⌘⌥S |
| Refresh | ⌘R |
| Hard Refresh | ⌘⇧R |

## Menu Integration

The app includes custom menu items:

- **OWUI URL Menu**: Reset URL functionality
- **Page Menu**: Screenshot, refresh, and hard refresh options

## Technical Details

### Architecture

- **SwiftUI**: Modern declarative UI framework
- **WebKit**: `WKWebView` for web content rendering
- **SwiftData**: Data persistence (currently minimal usage)
- **AppKit**: macOS-specific functionality and window management

### Key Components

- `ContentView`: Main interface with URL input and WebView
- `WebView`: NSViewRepresentable wrapper for WKWebView
- `OWUIApp`: App entry point with menu commands and keyboard shortcuts
- `Item`: SwiftData model (currently unused but set up for future features)

### URL Validation

The app validates Open WebUI instances by:
1. Appending `/static/splash.png` to the provided URL
2. Making an HTTP request to check if the resource exists (200 status)
3. Only accepting URLs that return a valid splash image

### State Management

- Uses `UserDefaults` to persist the Open WebUI URL
- State is managed through SwiftUI's `@State` and `@Binding` properties
- `NotificationCenter` for communication between app components

## Development

### Project Structure

```
OWUI/
├── OWUI/
│   ├── ContentView.swift      # Main UI implementation
│   ├── OWUIApp.swift         # App entry point and commands
│   ├── Item.swift            # SwiftData model
│   └── Assets.xcassets/      # App icons and images
├── OWUITests/                # Unit tests
├── OWUIUITests/             # UI tests
└── OWUI.xcodeproj/          # Xcode project
```

### Building

1. Ensure you have Xcode installed
2. Open `OWUI.xcodeproj`
3. Select your target device/simulator
4. Build with ⌘B or run with ⌘R

### Testing

The project includes test targets:
- `OWUITests`: Unit tests
- `OWUIUITests`: UI automation tests

Run tests with ⌘U in Xcode.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

[Add your license information here]

## Support

For issues related to Open WebUI itself, visit the [Open WebUI repository](https://github.com/open-webui/open-webui).

For issues specific to this macOS client, please open an issue in this repository.
