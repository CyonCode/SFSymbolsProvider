import SwiftUI
import SFSymbolsProvider

@MainActor
enum IconManifest {
    @ViewBuilder
    static var phosphorIcons: some View {
        Image(icon: "ph.house")
        Image(icon: "ph.house.fill")
        Image(icon: "ph.house.bold")
        Image(icon: "ph.gear")
        Image(icon: "ph.gear.fill")
        Image(icon: "ph.star")
        Image(icon: "ph.star.fill")
        Image(icon: "ph.heart")
        Image(icon: "ph.heart.fill")
        Image(icon: "ph.user")
        Image(icon: "ph.user.fill")
    }
    
    @ViewBuilder
    static var ionicons: some View {
        Image(icon: "ion.home")
        Image(icon: "ion.home.outline")
        Image(icon: "ion.home.sharp")
        Image(icon: "ion.settings")
        Image(icon: "ion.settings.outline")
        Image(icon: "ion.star")
        Image(icon: "ion.star.outline")
        Image(icon: "ion.heart")
        Image(icon: "ion.heart.outline")
        Image(icon: "ion.person")
        Image(icon: "ion.person.outline")
    }
}
