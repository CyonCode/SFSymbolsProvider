import SwiftUI
import SFSymbolsProvider

@main
struct ExampleApp: App {
    init() {
        #if SWIFT_PACKAGE
        SFSymbolsProviderConfig.resourceBundle = .module
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
