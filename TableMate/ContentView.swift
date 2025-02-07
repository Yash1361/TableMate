import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TMHomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2")
                }
            
            AddEventView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
