import SwiftUI
import SFSymbolsProvider

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PhosphorIconsView()
                .tabItem {
                    Label("Phosphor", systemImage: "square.grid.2x2")
                }
                .tag(0)
            
            IoniconsView()
                .tabItem {
                    Label("Ionicons", systemImage: "square.grid.3x3")
                }
                .tag(1)
        }
    }
}

struct PhosphorIconsView: View {
    let icons = [
        "ph.house", "ph.house.fill", "ph.house.bold",
        "ph.gear", "ph.gear.fill",
        "ph.star", "ph.star.fill",
        "ph.heart", "ph.heart.fill",
        "ph.user", "ph.user.fill"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                    ForEach(icons, id: \.self) { iconName in
                        VStack {
                            if let image = Image(icon: iconName) {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "questionmark.square")
                                    .foregroundStyle(.red)
                            }
                            Text(iconName.replacingOccurrences(of: "ph.", with: ""))
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Phosphor Icons")
        }
    }
}

struct IoniconsView: View {
    let icons = [
        "ion.home", "ion.home.outline", "ion.home.sharp",
        "ion.settings", "ion.settings.outline",
        "ion.star", "ion.star.outline",
        "ion.heart", "ion.heart.outline",
        "ion.person", "ion.person.outline"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                    ForEach(icons, id: \.self) { iconName in
                        VStack {
                            if let image = Image(icon: iconName) {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.green)
                            } else {
                                Image(systemName: "questionmark.square")
                                    .foregroundStyle(.red)
                            }
                            Text(iconName.replacingOccurrences(of: "ion.", with: ""))
                                .font(.caption2)
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Ionicons")
        }
    }
}

#Preview {
    ContentView()
}
