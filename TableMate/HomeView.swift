import SwiftUI

// MARK: - Models

struct BusinessSearchResponse: Codable {
    let total: Int
    let businesses: [Business]
}

struct Business: Codable, Identifiable {
    let id: String
    let name: String
    let image_url: String?
    let url: String
    let review_count: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Coordinates
    let location: Location
    let price: String?
}

struct Category: Codable, Identifiable {
    let alias: String
    let title: String
    
    var id: String { alias }
}

struct Coordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct Location: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
}

// MARK: - ViewModel

class HomeViewModel: ObservableObject {
    @Published var featuredRestaurants: [Business] = []
    @Published var recommendedRestaurants: [Business] = []
    
    private let apiKey = "wsEhqlOsTtVjUW2ltj5j80fWMDG0jPMFf_X48NolfsDstqwmhBJitSAzFTFO1id0M2e5xaJVrlHHRDcg1nZUjVgyLQp5-KIpFlHXYNOVmXRXbCBA4wP9hG2cMj4MZ3Yx"
    
    private let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    init() {
        fetchFeaturedRestaurants()
        fetchRecommendedRestaurants()
    }
    
    func fetchFeaturedRestaurants() {
        // Example: Fetch top-rated restaurants as featured
        let latitude = 37.786882
        let longitude = -122.399972
        let limit = 5
        let sortBy = "rating"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort_by", value: sortBy)
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error fetching featured restaurants: \(response)")
                    return
                }
                
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(BusinessSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.featuredRestaurants = searchResponse.businesses
                }
            } catch {
                print("Error fetching featured restaurants: \(error)")
            }
        }
    }
    
    func fetchRecommendedRestaurants() {
        // Example: Fetch recommended restaurants based on a different sort or criteria
        let latitude = 37.786882
        let longitude = -122.399972
        let limit = 5
        let sortBy = "best_match"
        
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort_by", value: sortBy)
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error fetching recommended restaurants: \(response)")
                    return
                }
                
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(BusinessSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.recommendedRestaurants = searchResponse.businesses
                }
            } catch {
                print("Error fetching recommended restaurants: \(error)")
            }
        }
    }
}

// MARK: - HomeView

struct HomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showingProfileSheet = false
    @State private var showingNewEventSheet = false
    
    @StateObject private var viewModel = HomeViewModel()
    
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
    
    // MARK: - Sections
    
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
                    ForEach(viewModel.featuredRestaurants) { business in
                        FeaturedRestaurantCard(business: business)
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
                    ForEach(Cuisine.allCases) { cuisine in
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
                    ForEach(viewModel.recommendedRestaurants) { business in
                        RecommendedRestaurantCard(business: business)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Card Views

struct FeaturedRestaurantCard: View {
    let business: Business
    @Environment(\.openURL) var openURLEnvironment
    
    var body: some View {
        Button(action: {
            if let url = URL(string: business.url) {
                openURLEnvironment(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: business.image_url ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 250, height: 150)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 250, height: 150)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                VStack {
                                    Spacer()
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(business.name)
                                                .font(.custom("Didot", size: 18).weight(.semibold))
                                                .foregroundColor(.black) // Changed to black
                                                .padding(.bottom, 2)
                                            
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text(String(format: "%.1f", business.rating))
                                                    .font(.custom("Avenir", size: 12).weight(.medium))
                                                    .foregroundColor(.black) // Changed to black
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.7)) // Added semi-transparent background
                                    .cornerRadius(8)
                                    .padding([.leading, .bottom, .trailing], 8)
                                }
                            )
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 150)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Text("\(business.categories.map { $0.title }.joined(separator: ", "))")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
                
                Text("\(formattedDistance(latitude: business.coordinates.latitude, longitude: business.coordinates.longitude)) miles away")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(width: 250)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formattedDistance(latitude: Double?, longitude: Double?) -> String {
        guard let lat = latitude, let lon = longitude else { return "N/A" }
        // Placeholder for distance. Implement actual distance calculation if needed.
        return "2.5"
    }
}

struct RecommendedRestaurantCard: View {
    let business: Business
    @Environment(\.openURL) var openURLEnvironment
    
    var body: some View {
        Button(action: {
            if let url = URL(string: business.url) {
                openURLEnvironment(url)
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: business.image_url ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 200, height: 120)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 120)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 120)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(12)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Text(business.name)
                    .font(.custom("Didot", size: 16).weight(.semibold))
                
                HStack {
                    ForEach(business.categories.prefix(2)) { category in
                        Text(category.title)
                            .font(.custom("Avenir", size: 12))
                            .padding(4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    Text(String(format: "%.1f", business.rating))
                        .font(.custom("Avenir", size: 12).weight(.medium))
                    Text("(\(business.review_count))")
                        .font(.custom("Avenir", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UpcomingReservationCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Placeholder for reservation details
            AsyncImage(url: URL(string: "https://picsum.photos/400/200")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(16)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(16)
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
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(16)
                @unknown default:
                    EmptyView()
                }
            }
            
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

struct TrendingDishCard: View {
    let id = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: "https://picsum.photos/200")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
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
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                @unknown default:
                    EmptyView()
                }
            }
            
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
            AsyncImage(url: URL(string: "https://picsum.photos/400/200")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 120)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(12)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                @unknown default:
                    EmptyView()
                }
            }
            
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

struct FriendActivityRow: View {
    let id = UUID()
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: "https://picsum.photos/100")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
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

// MARK: - Enumerations

enum Cuisine: String, CaseIterable, Identifiable {
    case italian = "Italian"
    case japanese = "Japanese"
    case mexican = "Mexican"
    case indian = "Indian"
    case chinese = "Chinese"
    case french = "French"
    case thai = "Thai"
    case american = "American"
    
    var id: String { self.rawValue }
    
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

// MARK: - Additional Views

struct NewEventView: View {
    var body: some View {
        Text("New Event View")
            .font(.largeTitle)
            .padding()
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
