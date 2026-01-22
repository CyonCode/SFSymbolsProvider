import SwiftUI
import SFSymbolsProvider

@main
struct ExampleApp: App {
    init() {
        SFSymbolsProviderConfig.resourceBundle = .module
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
