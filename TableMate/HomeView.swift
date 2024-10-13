import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showingProfileSheet = false
    @State private var showingNewEventSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    searchBar
                    quickActionsBar
                    upcomingReservation
                    featuredRestaurants
                    friendsActivitySection
                    popularCuisinesSection
                    trendingDishesSection
                    localEventsSection
                    recommendedForYouSection
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TableMate")
                        .font(.custom("Didot", size: 24, relativeTo: .title)
                              .weight(.semibold))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingProfileSheet = true }) {
                        Image(systemName: "person.crop.circle")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingProfileSheet) {
            ProfileView()
        }
        .sheet(isPresented: $showingNewEventSheet) {
            NewEventView()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search restaurants, cuisines, or friends", text: $searchText)
                .font(.custom("Avenir", size: 16))
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var quickActionsBar: some View {
        HStack(spacing: 20) {
            QuickActionButton(icon: "calendar.badge.plus", title: "New Event") {
                showingNewEventSheet = true
            }
            QuickActionButton(icon: "fork.knife", title: "Find Restaurant") {
                // Action to find restaurant
            }
            QuickActionButton(icon: "person.2.fill", title: "Invite Friends") {
                // Action to invite friends
            }
        }
        .padding(.horizontal)
    }
    
    private var upcomingReservation: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Upcoming Reservation", action: {
                // Action to view all reservations
            })
            
            UpcomingReservationCard()
        }
    }
    
    private var featuredRestaurants: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Featured Restaurants", action: {
                // Action to view all featured restaurants
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        FeaturedRestaurantCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var friendsActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Friends' Activity", action: {
                // Action to view all friends' activity
            })
            
            VStack(spacing: 15) {
                ForEach(0..<3) { _ in
                    FriendActivityRow()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var popularCuisinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Popular Cuisines", action: {
                // Action to view all cuisines
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Cuisine.allCases, id: \.self) { cuisine in
                        CuisineButton(cuisine: cuisine)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var trendingDishesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Trending Dishes", action: {
                // Action to view all trending dishes
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        TrendingDishCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var localEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Local Events", action: {
                // Action to view all local events
            })
            
            VStack(spacing: 15) {
                ForEach(0..<2) { _ in
                    LocalEventCard()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var recommendedForYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Recommended for You", action: {
                // Action to view all recommendations
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        RecommendedRestaurantCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text(title)
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SectionHeader: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Didot", size: 20, relativeTo: .title3).weight(.semibold))
            Spacer()
            Button("See All") {
                action()
            }
            .font(.custom("Avenir", size: 14).weight(.medium))
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
}

struct UpcomingReservationCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteImage(url: "https://picsum.photos/400/200", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]),
                                   startPoint: .bottom,
                                   endPoint: .top)
                )
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("La Bella Italia")
                                    .font(.custom("Didot", size: 22).weight(.bold))
                                    .foregroundColor(.white)
                                Text("Italian cuisine • 4 people")
                                    .font(.custom("Avenir", size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding()
                    }
                )
            
            HStack {
                Label("Today, 7:30 PM", systemImage: "calendar")
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("View Details") {
                    // Action to view details
                }
                .font(.custom("Avenir", size: 14).weight(.semibold))
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct FeaturedRestaurantCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(url: "https://picsum.photos/300/200", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(width: 250, height: 150)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Sushi Delight")
                                    .font(.custom("Didot", size: 18).weight(.semibold))
                                    .foregroundColor(.white)
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text("4.8")
                                        .font(.custom("Avenir", size: 12).weight(.medium))
                                        .foregroundColor(.white)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                                           startPoint: .bottom,
                                           endPoint: .top)
                        )
                    }
                )
            
            Text("Japanese • $$")
                .font(.custom("Avenir", size: 12))
                .foregroundColor(.secondary)
            
            Text("2.5 miles away")
                .font(.custom("Avenir", size: 12))
                .foregroundColor(.secondary)
        }
        .frame(width: 250)
    }
}

struct FriendActivityRow: View {
    let id = UUID()
    
    var body: some View {
        HStack(spacing: 15) {
            RemoteImage(url: "https://picsum.photos/100", id: id)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Sarah booked a table")
                    .font(.custom("Avenir", size: 14).weight(.semibold))
                
                Text("at Burger Palace for tomorrow")
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Join") {
                // Action to join
            }
            .font(.custom("Avenir", size: 14).weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

enum Cuisine: String, CaseIterable {
    case italian = "Italian"
    case japanese = "Japanese"
    case mexican = "Mexican"
    case indian = "Indian"
    case chinese = "Chinese"
    case french = "French"
    case thai = "Thai"
    case american = "American"
    
    var icon: String {
        switch self {
        case .italian: return "🍝"
        case .japanese: return "🍣"
        case .mexican: return "🌮"
        case .indian: return "🍛"
        case .chinese: return "🥡"
        case .french: return "🥐"
        case .thai: return "🍜"
        case .american: return "🍔"
        }
    }
}

struct CuisineButton: View {
    let cuisine: Cuisine
    
    var body: some View {
        VStack {
            Text(cuisine.icon)
                .font(.system(size: 36))
                .frame(width: 70, height: 70)
                .background(Color(.systemBackground))
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text(cuisine.rawValue)
                .font(.custom("Avenir", size: 12).weight(.medium))
                .foregroundColor(.primary)
        }
    }
}

struct TrendingDishCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(url: "https://picsum.photos/200", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    VStack {
                        Spacer()
                        Text("Truffle Pasta")
                            .font(.custom("Didot", size: 16).weight(.semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.6))
                    }
                )
            
            Text("Italian Bistro")
                .font(.custom("Avenir", size: 12).weight(.medium))
            
            Text("$24")
                .font(.custom("Avenir", size: 12))
                .foregroundColor(.secondary)
        }
        .frame(width: 150)
    }
}

struct LocalEventCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteImage(url: "https://picsum.photos/400/200", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(height: 120)
                .clipped()
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Wine Tasting Evening")
                    .font(.custom("Didot", size: 18).weight(.semibold))
                
                Text("Explore a variety of local wines")
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("This Friday, 7:00 PM")
                        .font(.custom("Avenir", size: 12).weight(.medium))
                    
                    Spacer()
                    
                    Button("Join") {
                        // Action to join event
                    }
                    .font(.custom("Avenir", size: 12).weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct RecommendedRestaurantCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RemoteImage(url: "https://picsum.photos/300/200", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 120)
                .clipped()
                .cornerRadius(12)
            
            Text("Green Garden Cafe")
                .font(.custom("Didot", size: 16).weight(.semibold))
            
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Vegetarian")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 12))
                Text("4.6")
                    .font(.custom("Avenir", size: 12).weight(.medium))
                Text("(218)")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200)
    }
}

struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .blue : .gray)
                Text(title)
                    .font(.custom("Avenir", size: 10))
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
    }
}

struct NewEventView: View {
    var body: some View {
        Text("New Event View")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
