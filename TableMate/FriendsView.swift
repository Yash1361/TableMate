import SwiftUI

struct FriendsView: View {
    @State private var selectedView: FriendsViewType = .activity
    @State private var showingInviteSheet = false
    @State private var searchText = ""
    
    enum FriendsViewType {
        case activity, current, suggestions
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                customSegmentedControl
                
                searchBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedView {
                        case .activity:
                            FriendsActivityFeed()
                        case .current:
                            CurrentFriendsList(searchText: searchText)
                        case .suggestions:
                            SuggestedFriendsList()
                        }
                    }
                    .padding(.top)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Friends")
                        .font(.custom("Didot", size: 24, relativeTo: .title).weight(.semibold))
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingInviteSheet = true }) {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(.primary)
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
            segmentButton(for: .activity, title: "Activity")
            segmentButton(for: .current, title: "Friends")
            segmentButton(for: .suggestions, title: "Discover")
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .padding()
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func segmentButton(for type: FriendsViewType, title: String) -> some View {
        Button(action: { selectedView = type }) {
            Text(title)
                .font(.custom("Avenir", size: 16).weight(.medium))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedView == type ? Color.blue.opacity(0.1) : Color.clear)
                .foregroundColor(selectedView == type ? .blue : .gray)
        }
        .cornerRadius(20)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search friends", text: $searchText)
                .font(.custom("Avenir", size: 16))
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

struct FriendsActivityFeed: View {
    let activities: [FriendActivity] = [
        FriendActivity(friendName: "Emma", action: "reviewed", restaurant: "Sushi Haven", rating: 4.5, comment: "Amazing sushi, great atmosphere!"),
        FriendActivity(friendName: "Liam", action: "visited", restaurant: "Burger Bliss", rating: nil, comment: nil),
        FriendActivity(friendName: "Olivia", action: "recommended", restaurant: "Pasta Paradise", rating: 5.0, comment: "Best pasta in town, you must try it!"),
        FriendActivity(friendName: "Noah", action: "reserved", restaurant: "Steak House Deluxe", rating: nil, comment: nil),
        FriendActivity(friendName: "Ava", action: "reviewed", restaurant: "Taco Fiesta", rating: 4.0, comment: "Authentic flavors, but a bit crowded"),
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(activity.friendName.prefix(1))
                            .font(.custom("Avenir", size: 18).weight(.bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.friendName)
                        .font(.custom("Avenir", size: 16).weight(.semibold))
                    
                    Text("\(activity.action) \(activity.restaurant)")
                        .font(.custom("Avenir", size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(timeAgo())
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            
            if let rating = activity.rating {
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                    Text(String(format: "%.1f", rating))
                        .font(.custom("Avenir", size: 12).weight(.medium))
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
                Button(action: {}) {
                    Image(systemName: "hand.thumbsup")
                    Text("Like")
                }
                .font(.custom("Avenir", size: 14).weight(.medium))
                .foregroundColor(.blue)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                    Text("Comment")
                }
                .font(.custom("Avenir", size: 14).weight(.medium))
                .foregroundColor(.blue)
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

struct CurrentFriendsList: View {
    let searchText: String
    
    let friends = [
        Friend(name: "Emma", foodPreference: "Sushi lover", mutualFriends: 15),
        Friend(name: "Liam", foodPreference: "BBQ enthusiast", mutualFriends: 8),
        Friend(name: "Olivia", foodPreference: "Vegan foodie", mutualFriends: 20),
        Friend(name: "Noah", foodPreference: "Italian cuisine fan", mutualFriends: 12),
        Friend(name: "Ava", foodPreference: "Dessert connoisseur", mutualFriends: 18),
        Friend(name: "Ethan", foodPreference: "Spicy food addict", mutualFriends: 6),
        Friend(name: "Sophia", foodPreference: "Farm-to-table advocate", mutualFriends: 10),
        Friend(name: "Mason", foodPreference: "Craft beer enthusiast", mutualFriends: 14),
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
                FriendRow(friend: friend)
            }
        }
        .padding(.horizontal)
    }
}

struct FriendRow: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(friend.name.prefix(1))
                        .font(.custom("Avenir", size: 20).weight(.bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.custom("Avenir", size: 16).weight(.semibold))
                
                Text(friend.foodPreference)
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.secondary)
                
                Text("\(friend.mutualFriends) mutual friends")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Message")
                    .font(.custom("Avenir", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SuggestedFriendsList: View {
    let suggestedFriends = [
        SuggestedFriend(name: "Mia", foodPreference: "Thai food enthusiast", mutualFriends: 5),
        SuggestedFriend(name: "James", foodPreference: "Molecular gastronomy fan", mutualFriends: 3),
        SuggestedFriend(name: "Charlotte", foodPreference: "Organic and local food advocate", mutualFriends: 7),
        SuggestedFriend(name: "William", foodPreference: "Food truck explorer", mutualFriends: 2),
        SuggestedFriend(name: "Amelia", foodPreference: "Mediterranean diet follower", mutualFriends: 4),
        SuggestedFriend(name: "Benjamin", foodPreference: "Comfort food lover", mutualFriends: 6),
    ]
    
    var body: some View {
        LazyVStack(spacing: 20) {
            ForEach(suggestedFriends) { friend in
                SuggestedFriendRow(friend: friend)
            }
        }
        .padding(.horizontal)
    }
}

struct SuggestedFriendRow: View {
    let friend: SuggestedFriend
    
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.green)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(friend.name.prefix(1))
                        .font(.custom("Avenir", size: 20).weight(.bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.custom("Avenir", size: 16).weight(.semibold))
                
                Text(friend.foodPreference)
                    .font(.custom("Avenir", size: 14))
                    .foregroundColor(.secondary)
                
                Text("\(friend.mutualFriends) mutual friends")
                    .font(.custom("Avenir", size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("Add Friend")
                    .font(.custom("Avenir", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct InviteFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Invite Friends to TableMate")
                    .font(.custom("Didot", size: 24).weight(.semibold))
                
                Text("Share the joy of dining with your friends!")
                    .font(.custom("Avenir", size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Enter friend's email", text: $email)
                    .font(.custom("Avenir", size: 16))
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                Button(action: {
                    // Send invitation logic here
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Send Invitation")
                        .font(.custom("Avenir", size: 16).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Invite Friends", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FriendActivity: Identifiable {
    let id = UUID()
    let friendName: String
    let action: String
    let restaurant: String
    let rating: Double?
    let comment: String?
}

struct Friend: Identifiable {
    let id = UUID()
    let name: String
    let foodPreference: String
    let mutualFriends: Int
}

struct SuggestedFriend: Identifiable {
    let id = UUID()
    let name: String
    let foodPreference: String
    let mutualFriends: Int
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}

// MARK: - Additional Components

struct FoodPreferenceTag: View {
    let preference: String
    
    var body: some View {
        Text(preference)
            .font(.custom("Avenir", size: 12).weight(.medium))
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

// MARK: - Enhanced Friend Rows

struct EnhancedFriendRow: View {
    let friend: Friend
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(friend.name.prefix(1))
                            .font(.custom("Avenir", size: 24).weight(.bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.custom("Avenir", size: 18).weight(.semibold))
                    
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
                        .font(.custom("Avenir", size: 16).weight(.semibold))
                    
                    HStack {
                        RecentActivityIndicator()
                        Text("Visited Sushi Haven")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        RecentActivityIndicator()
                        Text("Reviewed Pasta Paradise (4.5 stars)")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    Button(action: {}) {
                        Text("View Full Profile")
                            .font(.custom("Avenir", size: 14).weight(.medium))
                            .foregroundColor(.blue)
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

struct EnhancedSuggestedFriendRow: View {
    let friend: SuggestedFriend
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 15) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(friend.name.prefix(1))
                            .font(.custom("Avenir", size: 24).weight(.bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(friend.name)
                        .font(.custom("Avenir", size: 18).weight(.semibold))
                    
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
                        .font(.custom("Avenir", size: 16).weight(.semibold))
                    
                    HStack {
                        Image(systemName: "hand.thumbsup.fill")
                            .foregroundColor(.blue)
                        Text("Similar food preferences")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text("Friends with \(friend.mutualFriends) of your friends")
                            .font(.custom("Avenir", size: 14))
                    }
                    
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            Text("Add Friend")
                                .font(.custom("Avenir", size: 14).weight(.medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .cornerRadius(20)
                        }
                        
                        Button(action: {}) {
                            Text("Ignore")
                                .font(.custom("Avenir", size: 14).weight(.medium))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray5))
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

// MARK: - Enhanced Lists

struct EnhancedCurrentFriendsList: View {
    let searchText: String
    
    let friends = [
        Friend(name: "Emma", foodPreference: "Sushi lover", mutualFriends: 15),
        Friend(name: "Liam", foodPreference: "BBQ enthusiast", mutualFriends: 8),
        Friend(name: "Olivia", foodPreference: "Vegan foodie", mutualFriends: 20),
        Friend(name: "Noah", foodPreference: "Italian cuisine fan", mutualFriends: 12),
        Friend(name: "Ava", foodPreference: "Dessert connoisseur", mutualFriends: 18),
        Friend(name: "Ethan", foodPreference: "Spicy food addict", mutualFriends: 6),
        Friend(name: "Sophia", foodPreference: "Farm-to-table advocate", mutualFriends: 10),
        Friend(name: "Mason", foodPreference: "Craft beer enthusiast", mutualFriends: 14),
    ]
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(filteredFriends) { friend in
                    EnhancedFriendRow(friend: friend)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct EnhancedSuggestedFriendsList: View {
    let suggestedFriends = [
        SuggestedFriend(name: "Mia", foodPreference: "Thai food enthusiast", mutualFriends: 5),
        SuggestedFriend(name: "James", foodPreference: "Molecular gastronomy fan", mutualFriends: 3),
        SuggestedFriend(name: "Charlotte", foodPreference: "Organic and local food advocate", mutualFriends: 7),
        SuggestedFriend(name: "William", foodPreference: "Food truck explorer", mutualFriends: 2),
        SuggestedFriend(name: "Amelia", foodPreference: "Mediterranean diet follower", mutualFriends: 4),
        SuggestedFriend(name: "Benjamin", foodPreference: "Comfort food lover", mutualFriends: 6),
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(suggestedFriends) { friend in
                    EnhancedSuggestedFriendRow(friend: friend)
                }
            }
            .padding(.horizontal)
        }
    }
}
