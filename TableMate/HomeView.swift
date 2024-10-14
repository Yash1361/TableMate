import SwiftUI

// MARK: - Models

struct TMBusinessSearchResponse: Codable {
    let total: Int
    let businesses: [TMBusiness]
}

struct TMBusiness: Codable, Identifiable {
    let id: String
    let name: String
    let image_url: String?
    let url: String
    let review_count: Int
    let categories: [TMCategory]
    let rating: Double
    let coordinates: TMCoordinates
    let location: TMLocation
    let price: String?
}

struct TMCategory: Codable, Identifiable {
    let alias: String
    let title: String
    
    var id: String { alias }
}

struct TMCoordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct TMLocation: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
}

// MARK: - ViewModels

class TMHomeViewModel: ObservableObject {
    @Published var featuredRestaurants: [TMBusiness] = []
    @Published var recommendedRestaurants: [TMBusiness] = []
    
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
                let searchResponse = try decoder.decode(TMBusinessSearchResponse.self, from: data)
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
                let searchResponse = try decoder.decode(TMBusinessSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.recommendedRestaurants = searchResponse.businesses
                }
            } catch {
                print("Error fetching recommended restaurants: \(error)")
            }
        }
    }
}

class TMRestaurantSearchViewModel: ObservableObject {
    @Published var restaurants: [TMBusiness] = []
    @Published var searchText: String = ""
    @Published var selectedCuisine: Cuisine? = nil
    @Published var selectedSortOption: SortOption = .bestMatch
    @Published var isLoading: Bool = false
    
    private let apiKey = "wsEhqlOsTtVjUW2ltj5j80fWMDG0jPMFf_X48NolfsDstqwmhBJitSAzFTFO1id0M2e5xaJVrlHHRDcg1nZUjVgyLQp5-KIpFlHXYNOVmXRXbCBA4wP9hG2cMj4MZ3Yx"
    private let baseURL = "https://api.yelp.com/v3/businesses/search"
    
    enum SortOption: String, CaseIterable, Identifiable {
        case bestMatch = "Best Match"
        case rating = "Rating"
        case reviewCount = "Review Count"
        case distance = "Distance"
        
        var id: String { self.rawValue }
        
        var yelpValue: String {
            switch self {
            case .bestMatch: return "best_match"
            case .rating: return "rating"
            case .reviewCount: return "review_count"
            case .distance: return "distance"
            }
        }
    }
    
    init() {
        // Initial fetch if needed
    }
    
    func fetchRestaurants(latitude: Double, longitude: Double) {
        isLoading = true
        var components = URLComponents(string: baseURL)!
        
        var queryItems = [
            URLQueryItem(name: "term", value: "restaurants"),
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longitude)"),
            URLQueryItem(name: "limit", value: "50")
        ]
        
        if !searchText.isEmpty {
            queryItems.append(URLQueryItem(name: "term", value: searchText))
        }
        
        if let cuisine = selectedCuisine {
            queryItems.append(URLQueryItem(name: "categories", value: cuisine.rawValue.lowercased()))
        }
        
        queryItems.append(URLQueryItem(name: "sort_by", value: selectedSortOption.yelpValue))
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error fetching restaurants: \(response)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(TMBusinessSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.restaurants = searchResponse.businesses
                    self.isLoading = false
                }
            } catch {
                print("Error fetching restaurants: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - HomeView

struct TMHomeView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showingProfileSheet = false
    @State private var showingNewEventSheet = false
    @State private var navigateToSearch = false
    @State private var selectedCuisineForSearch: Cuisine? = nil
    
    @StateObject private var viewModel = TMHomeViewModel()
    
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
            .background(
                NavigationLink(
                    destination: TMRestaurantSearchView(selectedCuisine: selectedCuisineForSearch),
                    isActive: $navigateToSearch,
                    label: { EmptyView() }
                )
            )
        }
        .sheet(isPresented: $showingProfileSheet) {
            TMProfileView()
        }
        .sheet(isPresented: $showingNewEventSheet) {
            TMNewEventView()
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
            TMQuickActionButton(icon: "calendar.badge.plus", title: "New Event") {
                showingNewEventSheet = true
            }
            TMQuickActionButton(icon: "fork.knife", title: "Find Restaurant") {
                navigateToSearch = true
            }
            TMQuickActionButton(icon: "person.2.fill", title: "Invite Friends") {
                // Action to invite friends
            }
        }
        .padding(.horizontal)
    }
    
    private var upcomingReservation: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Upcoming Reservation", action: {
                // Action to view all reservations
            })
            
            TMUpcomingReservationCard()
        }
    }
    
    private var featuredRestaurants: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Featured Restaurants", action: {
                // Action to view all featured restaurants
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.featuredRestaurants) { business in
                        TMFeaturedRestaurantCard(business: business)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var friendsActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Friends' Activity", action: {
                // Action to view all friends' activity
            })
            
            VStack(spacing: 15) {
                ForEach(0..<3) { _ in
                    TMFriendActivityRow()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var popularCuisinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Popular Cuisines", action: {
                // Action to view all cuisines
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Cuisine.allCases) { cuisine in
                        TMCuisineButton(cuisine: cuisine) {
                            selectedCuisineForSearch = cuisine
                            navigateToSearch = true
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var trendingDishesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Trending Dishes", action: {
                // Action to view all trending dishes
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<5) { _ in
                        TMTrendingDishCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var localEventsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Local Events", action: {
                // Action to view all local events
            })
            
            VStack(spacing: 15) {
                ForEach(0..<2) { _ in
                    TMLocalEventCard()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var recommendedForYouSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TMSectionHeader(title: "Recommended for You", action: {
                // Action to view all recommendations
            })
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.recommendedRestaurants) { business in
                        TMRecommendedRestaurantCard(business: business)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Restaurant Search View

struct TMRestaurantSearchView: View {
    @StateObject private var viewModel = TMRestaurantSearchViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var selectedCuisine: Cuisine?
    
    // Example coordinates; in a real app, use user's current location
    let latitude = 37.786882
    let longitude = -122.399972
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search for restaurants", text: $viewModel.searchText, onCommit: {
                        viewModel.fetchRestaurants(latitude: latitude, longitude: longitude)
                    })
                    .font(.custom("Avenir", size: 16))
                    .autocapitalization(.none)
                }
                .padding(12)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Filters and Sort Options
                HStack {
                    // Sort Picker
                    Picker("Sort By", selection: $viewModel.selectedSortOption) {
                        ForEach(TMRestaurantSearchViewModel.SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.custom("Avenir", size: 14))
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        // Reset Filters
                        viewModel.selectedCuisine = nil
                        viewModel.searchText = ""
                        viewModel.selectedSortOption = .bestMatch
                        viewModel.fetchRestaurants(latitude: latitude, longitude: longitude)
                    }) {
                        Text("Reset")
                            .font(.custom("Avenir", size: 14).weight(.medium))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
            }
            .padding(.top)
            
            // List of Restaurants
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else {
                List(viewModel.restaurants) { business in
                    TMRestaurantRow(business: business)
                        .listRowInsets(EdgeInsets())
                        .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("Find Restaurants", displayMode: .inline)
        .navigationBarItems(trailing: Button("Done") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            if let cuisine = selectedCuisine {
                viewModel.selectedCuisine = cuisine
            }
            viewModel.fetchRestaurants(latitude: latitude, longitude: longitude)
        }
    }
}

// MARK: - Restaurant Row

struct TMRestaurantRow: View {
    let business: TMBusiness
    @Environment(\.openURL) var openURLEnvironment
    
    var body: some View {
        Button(action: {
            if let url = URL(string: business.url) {
                openURLEnvironment(url)
            }
        }) {
            HStack(alignment: .top, spacing: 15) {
                AsyncImage(url: URL(string: business.image_url ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(business.name)
                        .font(.custom("Didot", size: 18).weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text(business.location.address1 ?? "")
                        .font(.custom("Avenir", size: 14))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", business.rating))
                            .font(.custom("Avenir", size: 14).weight(.medium))
                        Text("(\(business.review_count))")
                            .font(.custom("Avenir", size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(business.categories.map { $0.title }.joined(separator: ", "))
                            .font(.custom("Avenir", size: 12))
                            .foregroundColor(.secondary)
                        Spacer()
                        if let price = business.price {
                            Text(price)
                                .font(.custom("Avenir", size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Additional Views

struct TMProfileView: View {
    var body: some View {
        Text("Profile View")
            .font(.largeTitle)
            .padding()
    }
}

struct TMNewEventView: View {
    var body: some View {
        Text("New Event View")
            .font(.largeTitle)
            .padding()
    }
}

// MARK: - Card Views

struct TMFeaturedRestaurantCard: View {
    let business: TMBusiness
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
                                                .foregroundColor(.black)
                                                .padding(.bottom, 2)
                                            
                                            HStack {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                                Text(String(format: "%.1f", business.rating))
                                                    .font(.custom("Avenir", size: 12).weight(.medium))
                                                    .foregroundColor(.black)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.7))
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

struct TMRecommendedRestaurantCard: View {
    let business: TMBusiness
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

struct TMUpcomingReservationCard: View {
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

struct TMTrendingDishCard: View {
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

struct TMLocalEventCard: View {
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

struct TMFriendActivityRow: View {
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

struct TMSectionHeader: View {
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

struct TMQuickActionButton: View {
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

struct TMCuisineButton: View {
    let cuisine: Cuisine
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
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
}

// MARK: - Preview

struct TMHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TMHomeView()
    }
}
