import SwiftUI

struct FriendsView: View {
    @State private var selectedView: FriendsViewType = .activity
    @State private var showingInviteSheet = false
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    enum FriendsViewType: String, CaseIterable {
        case activity = "Activity"
        case current = "Friends"
        case suggestions = "Discover"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                customSegmentedControl
                
                if selectedView != .activity {
                    searchBar
                }
                
                ScrollView {
                    PullToRefresh(coordinateSpaceName: "pullToRefresh", onRefresh: refreshData)
                    
                    VStack(spacing: 20) {
                        switch selectedView {
                        case .activity:
                            FriendsActivityFeed()
                        case .current:
                            EnhancedCurrentFriendsList(searchText: searchText)
                        case .suggestions:
                            EnhancedSuggestedFriendsList()
                        }
                    }
                    .padding(.top)
                }
                .coordinateSpace(name: "pullToRefresh")
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Friends")
                        .font(.custom("Didot-Bold", size: 28))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInviteSheet = true }) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingInviteSheet) {
            InviteFriendsView()
        }
    }
    
    private var customSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(FriendsViewType.allCases, id: \.self) { viewType in
                segmentButton(for: viewType)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func segmentButton(for type: FriendsViewType) -> some View {
        Button(action: { selectedView = type }) {
            VStack(spacing: 4) {
                Image(systemName: iconFor(type))
                    .font(.system(size: 24))
                Text(type.rawValue)
                    .font(.custom("Avenir-Medium", size: 12))
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(selectedView == type ? Color.blue.opacity(0.1) : Color.clear)
            .foregroundColor(selectedView == type ? .blue : .gray)
        }
        .cornerRadius(20)
    }
    
    private func iconFor(_ type: FriendsViewType) -> String {
        switch type {
        case .activity: return "bolt.fill"
        case .current: return "person.2.fill"
        case .suggestions: return "sparkles"
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search friends or restaurants", text: $searchText)
                .font(.custom("Avenir", size: 16))
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func refreshData() {
        isRefreshing = true
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRefreshing = false
        }
    }
}

struct FriendsActivityFeed: View {
    let activities: [FriendActivity] = [
        FriendActivity(friendName: "Emma", action: "reviewed", restaurant: "Sushi Haven", rating: 4.5, comment: "Amazing sushi, great atmosphere!", image: "https://picsum.photos/seed/sushi/300/200"),
        FriendActivity(friendName: "Liam", action: "visited", restaurant: "Burger Bliss", rating: nil, comment: nil, image: "https://picsum.photos/seed/burger/300/200"),
        FriendActivity(friendName: "Olivia", action: "recommended", restaurant: "Pasta Paradise", rating: 5.0, comment: "Best pasta in town, you must try it!", image: "https://picsum.photos/seed/pasta/300/200"),
        FriendActivity(friendName: "Noah", action: "reserved", restaurant: "Steak House Deluxe", rating: nil, comment: nil, image: "https://picsum.photos/seed/steak/300/200"),
        FriendActivity(friendName: "Ava", action: "reviewed", restaurant: "Taco Fiesta", rating: 4.0, comment: "Authentic flavors, but a bit crowded", image: "https://picsum.photos/seed/taco/300/200"),
    ]
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(activities) { activity in
                FriendActivityCard(activity: activity)
            }
        }
        .padding(.horizontal)
    }
}

struct FriendActivityCard: View {
    let activity: FriendActivity
    @State private var isLiked = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RemoteImage(url: "https://picsum.photos/seed/\(activity.friendName)/100", id: activity.id)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.friendName)
                        .font(.custom("Avenir-Heavy", size: 16))
                    
                    Text("\(activity.action) \(activity.restaurant)")
                        .font(.custom("Avenir", size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgo())
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            
            RemoteImage(url: activity.image, id: activity.id)
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .cornerRadius(12)
            
            if let rating = activity.rating {
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.custom("Avenir-Medium", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            if let comment = activity.comment {
                Text(comment)
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            
            HStack {
                Button(action: { isLiked.toggle() }) {
                    HStack {
                        Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        Text(isLiked ? "Liked" : "Like")
                    }
                }
                .font(.custom("Avenir-Medium", size: 14))
                .foregroundColor(isLiked ? .blue : .gray)
                
                Spacer()
                
                Button(action: { showComments.toggle() }) {
                    HStack {
                        Image(systemName: "bubble.right")
                        Text(showComments ? "Hide Comments" : "Show Comments")
                    }
                }
                .font(.custom("Avenir-Medium", size: 14))
                .foregroundColor(.gray)
            }
            
            if showComments {
                VStack(alignment: .leading, spacing: 8) {
                    CommentView(author: "Alex", comment: "Looks delicious! I need to try this place.")
                    CommentView(author: "Sophia", comment: "Great choice! Their desserts are amazing too.")
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func timeAgo() -> String {
        // This would normally calculate the time difference
        return "2h ago"
    }
}

struct CommentView: View {
    let author: String
    let comment: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RemoteImage(url: "https://picsum.photos/seed/\(author)/50", id: UUID())
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(author)
                    .font(.custom("Avenir-Heavy", size: 12))
                Text(comment)
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EnhancedCurrentFriendsList: View {
    let searchText: String
    
    let friends = [
        Friend(name: "Emma", foodPreference: "Sushi lover", mutualFriends: 15, favoriteRestaurant: "Sushi Haven"),
        Friend(name: "Liam", foodPreference: "BBQ enthusiast", mutualFriends: 8, favoriteRestaurant: "Smokey's Grill"),
        Friend(name: "Olivia", foodPreference: "Vegan foodie", mutualFriends: 20, favoriteRestaurant: "Green Leaf Cafe"),
        Friend(name: "Noah", foodPreference: "Italian cuisine fan", mutualFriends: 12, favoriteRestaurant: "Pasta Paradise"),
        Friend(name: "Ava", foodPreference: "Dessert connoisseur", mutualFriends: 18, favoriteRestaurant: "Sweet Treats Bakery"),
        Friend(name: "Ethan", foodPreference: "Spicy food addict", mutualFriends: 6, favoriteRestaurant: "Flaming Wok"),
        Friend(name: "Sophia", foodPreference: "Farm-to-table advocate", mutualFriends: 10, favoriteRestaurant: "Harvest Table"),
        Friend(name: "Mason", foodPreference: "Craft beer enthusiast", mutualFriends: 14, favoriteRestaurant: "Hoppy Brewpub"),
    ]
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(filteredFriends) { friend in
                EnhancedFriendRow(friend: friend)
            }
        }
        .padding(.horizontal)
    }
}

struct EnhancedFriendRow: View {
    let friend: Friend
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                RemoteImage(url: "https://picsum.photos/seed/\(friend.name)/200", id: friend.id)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.custom("Avenir-Heavy", size: 18))
                    
                    FoodPreferenceTag(preference: friend.foodPreference)
                    
                    MutualFriendsView(count: friend.mutualFriends)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.custom("Avenir-Heavy", size: 16))
                    
                    HStack {
                        RecentActivityIndicator()
                        Text("Visited \(friend.favoriteRestaurant)")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        RecentActivityIndicator()
                        Text("Left a review for Pasta Paradise (4.5 stars)")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        Button(action: {}) {
                            Label("View Full Profile", systemImage: "person.fill")
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Label("Message", systemImage: "message.fill")
                        }
                    }
                    .font(.custom("Avenir-Medium", size: 14))
                    .foregroundColor(.blue)
                }
                .padding(.leading, 75)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .animation(.spring(), value: isExpanded)
    }
}

struct EnhancedSuggestedFriendsList: View {
    let suggestedFriends = [
        SuggestedFriend(name: "Mia", foodPreference: "Thai food enthusiast", mutualFriends: 5, topRestaurant: "Bangkok Spice"),
        SuggestedFriend(name: "James", foodPreference: "Molecular gastronomy fan", mutualFriends: 3, topRestaurant: "The Lab Kitchen"),
        SuggestedFriend(name: "Charlotte", foodPreference: "Organic and local food advocate", mutualFriends: 7, topRestaurant: "Farm & Table"),
        SuggestedFriend(name: "William", foodPreference: "Food truck explorer", mutualFriends: 2, topRestaurant: "Rolling Flavors"),
        SuggestedFriend(name: "Amelia", foodPreference: "Mediterranean diet follower", mutualFriends: 4, topRestaurant: "Olive & Vine"),
        SuggestedFriend(name: "Benjamin", foodPreference: "Comfort food lover", mutualFriends: 6, topRestaurant: "Homestyle Diner"),
    ]
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(suggestedFriends) { friend in
                EnhancedSuggestedFriendRow(friend: friend)
            }
        }
        .padding(.horizontal)
    }
}

struct EnhancedSuggestedFriendRow: View {
    let friend: SuggestedFriend
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                RemoteImage(url: "https://picsum.photos/seed/\(friend.name)/200", id: friend.id)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.custom("Avenir-Heavy", size: 18))
                    
                    FoodPreferenceTag(preference: friend.foodPreference)
                    
                    MutualFriendsView(count: friend.mutualFriends)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Why you might like \(friend.name)")
                        .font(.custom("Avenir-Heavy", size: 16))
                    
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.orange)
                        Text("Shares your love for \(friend.foodPreference)")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Favorite restaurant: \(friend.topRestaurant)")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text("\(friend.mutualFriends) mutual friends")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            Label("Add Friend", systemImage: "person.badge.plus")
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        
                        Button(action: {}) {
                            Label("View Profile", systemImage: "person.fill")
                                .font(.custom("Avenir-Medium", size: 14))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.leading, 75)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .animation(.spring(), value: isExpanded)
    }
}

struct FoodPreferenceTag: View {
    let preference: String
    
    var body: some View {
        Text(preference)
            .font(.custom("Avenir-Medium", size: 12))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

struct MutualFriendsView: View {
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.2.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 12))
            Text("\(count) mutual")
                .font(.custom("Avenir", size: 12))
                .foregroundColor(.secondary)
        }
    }
}

struct RecentActivityIndicator: View {
    var body: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 10, height: 10)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}

struct InviteFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var invitationMessage = ""
    @State private var selectedContacts: [Contact] = []
    
    let contacts = [
        Contact(name: "Alice Johnson", email: "alice@example.com"),
        Contact(name: "Bob Smith", email: "bob@example.com"),
        Contact(name: "Charlie Brown", email: "charlie@example.com"),
        Contact(name: "Diana Ross", email: "diana@example.com"),
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("invite_friends_illustration")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                Text("Invite Friends to TableMate")
                    .font(.custom("Didot-Bold", size: 24))
                
                Text("Share the joy of dining with your friends!")
                    .font(.custom("Avenir", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Invite by Email")
                        .font(.custom("Avenir-Medium", size: 16))
                    
                    TextField("Enter friend's email", text: $email)
                        .font(.custom("Avenir", size: 16))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Personal Message")
                        .font(.custom("Avenir-Medium", size: 16))
                    
                    TextEditor(text: $invitationMessage)
                        .font(.custom("Avenir", size: 14))
                        .frame(height: 100)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Or invite from your contacts")
                        .font(.custom("Avenir-Medium", size: 16))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(contacts) { contact in
                                ContactBubble(contact: contact, isSelected: isContactSelected(contact)) {
                                    toggleContactSelection(contact)
                                }
                            }
                        }
                    }
                }
            
                
                Button(action: sendInvitations) {
                    Text("Send Invitations")
                        .font(.custom("Avenir-Heavy", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .navigationBarTitle("Invite Friends", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func isContactSelected(_ contact: Contact) -> Bool {
        selectedContacts.contains { $0.id == contact.id }
    }

    func toggleContactSelection(_ contact: Contact) {
        if isContactSelected(contact) {
            selectedContacts.removeAll { $0.id == contact.id }
        } else {
            selectedContacts.append(contact)
        }
    }
    
    func sendInvitations() {
        // Logic to send invitations
        presentationMode.wrappedValue.dismiss()
    }
}

struct ContactBubble: View {
    let contact: Contact
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.secondary)
                        .frame(width: 50, height: 50)
                    
                    Text(contact.name.prefix(1))
                        .font(.custom("Avenir-Heavy", size: 20))
                        .foregroundColor(.white)
                }
                
                Text(contact.name)
                    .font(.custom("Avenir", size: 12))
                    .lineLimit(1)
            }
        }
        .frame(width: 70)
    }
}

struct PullToRefresh: View {
    var coordinateSpaceName: String
    var onRefresh: () -> Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 1) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

struct FriendActivity: Identifiable {
    let id = UUID()
    let friendName: String
    let action: String
    let restaurant: String
    let rating: Double?
    let comment: String?
    let image: String
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let foodPreference: String
    let mutualFriends: Int
    let favoriteRestaurant: String
}

struct SuggestedFriend: Identifiable {
    let id = UUID()
    let name: String
    let foodPreference: String
    let mutualFriends: Int
    let topRestaurant: String
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let email: String
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
