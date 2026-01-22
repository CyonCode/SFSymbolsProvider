import SwiftUI
import SFSymbolsProvider

struct ContentView: View {
    var body: some View {
        TabView {
            IconGridView(
                title: "Phosphor Icons",
                icons: [
                    "ph.house", "ph.house.fill", "ph.house.bold",
                    "ph.gear", "ph.gear.fill",
                    "ph.star", "ph.star.fill",
                    "ph.heart", "ph.heart.fill",
                    "ph.user", "ph.user.fill"
                ],
                prefix: "ph.",
                tintColor: .blue
            )
            .tabItem { Label("Phosphor", systemImage: "square.grid.2x2") }

            IconGridView(
                title: "Ionicons",
                icons: [
                    "ion.home", "ion.home.outline", "ion.home.sharp",
                    "ion.settings", "ion.settings.outline",
                    "ion.star", "ion.star.outline",
                    "ion.heart", "ion.heart.outline",
                    "ion.person", "ion.person.outline"
                ],
                prefix: "ion.",
                tintColor: .green
            )
            .tabItem { Label("Ionicons", systemImage: "square.grid.3x3") }
        }
    }
}

struct IconGridView: View {
    let title: String
    let icons: [String]
    let prefix: String
    let tintColor: Color

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                    ForEach(icons, id: \.self) { iconName in
                        IconCell(iconName: iconName, prefix: prefix, tintColor: tintColor)
                    }
                }
                .padding()
            }
            .navigationTitle(title)
        }
    }
}

struct IconCell: View {
    let iconName: String
    let prefix: String
    let tintColor: Color

    var body: some View {
        VStack {
            if let image = Image(icon: iconName) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundStyle(tintColor)
            } else {
                Image(systemName: "questionmark.square")
                    .foregroundStyle(.red)
            }
            Text(iconName.replacingOccurrences(of: prefix, with: ""))
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

#Preview {
    ContentView()
}
