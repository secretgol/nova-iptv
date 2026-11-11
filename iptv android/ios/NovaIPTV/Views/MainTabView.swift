import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            ChannelsView()
                .tabItem {
                    Label("Canlı TV", systemImage: "tv.fill")
                }
                .tag(0)

            CategoriesView()
                .tabItem {
                    Label("Kategoriler", systemImage: "square.grid.2x2.fill")
                }
                .tag(1)

            FavoritesView()
                .tabItem {
                    Label("Favoriler", systemImage: "star.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
    }
}
