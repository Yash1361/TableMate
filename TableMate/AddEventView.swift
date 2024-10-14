import SwiftUI

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    @State private var groupSize = 2
    @State private var selectedFriends: [Friend] = []
    @State private var manualMembers: [ManualMember] = []
    @State private var showingSummary = false
    @State private var userPreferences = UserPreferences()
    @State private var showingRestaurants = false
    
    let steps = ["Group Size", "Add Members", "Preferences", "Summary"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                StepProgressView(currentStep: $currentStep, steps: steps)
                    .padding()
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0:
                            GroupSizeSelectionView(groupSize: $groupSize)
                        case 1:
                            AddMembersView(selectedFriends: $selectedFriends, manualMembers: $manualMembers, groupSize: groupSize)
                        case 2:
                            PreferencesView(userPreferences: $userPreferences)
                        case 3:
                            SummaryView(selectedFriends: selectedFriends, manualMembers: manualMembers, userPreferences: userPreferences)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                
                navigationButtons
            }
            .navigationBarTitle("Create Event", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showingRestaurants) {
                RestaurantsFoundView()
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button(action: { currentStep -= 1 }) {
                    Text("Back")
                        .fontWeight(.medium)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            if currentStep < steps.count - 1 {
                Button(action: { currentStep += 1 }) {
                    Text("Next")
                        .fontWeight(.medium)
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                Button(action: {
                    showingRestaurants = true
                }) {
                    Text("Find Restaurants")
                        .fontWeight(.medium)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct StepProgressView: View {
    @Binding var currentStep: Int
    let steps: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<steps.count) { index in
                VStack {
                    Circle()
                        .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Text("\(index + 1)")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        )
                    
                    Text(steps[index])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                }
                
                if index < steps.count - 1 {
                    Capsule()
                        .fill(index < currentStep ? Color.blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
    }
}

struct GroupSizeSelectionView: View {
    @Binding var groupSize: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("How many people are joining?")
                .font(.headline)
            
            Stepper(value: $groupSize, in: 2...10) {
                HStack {
                    Text("Group Size:")
                    Text("\(groupSize)")
                        .foregroundColor(.blue)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
    }
}

struct AddMembersView: View {
    @Binding var selectedFriends: [Friend]
    @Binding var manualMembers: [ManualMember]
    let groupSize: Int
    @State private var showingFriendsList = false
    @State private var showingManualEntry = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Add up to \(groupSize) members")
                .font(.headline)
            
            Button(action: { showingFriendsList = true }) {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("Add Friends")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            
            Button(action: { showingManualEntry = true }) {
                HStack {
                    Image(systemName: "person.fill.badge.plus")
                    Text("Add Manually")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            
            if !selectedFriends.isEmpty {
                Text("Selected Friends:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(selectedFriends) { friend in
                    HStack {
                        Text(friend.name)
                        Spacer()
                        Button(action: { removeFriend(friend) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            if !manualMembers.isEmpty {
                Text("Manually Added Members:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(manualMembers) { member in
                    HStack {
                        Text(member.name)
                        Spacer()
                        Button(action: { removeManualMember(member) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .sheet(isPresented: $showingFriendsList) {
            FriendsListView(selectedFriends: $selectedFriends, maxSelection: groupSize - manualMembers.count)
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualMemberEntryView(manualMembers: $manualMembers, maxMembers: groupSize - selectedFriends.count)
        }
    }
    
    private func removeFriend(_ friend: Friend) {
        selectedFriends.removeAll { $0.id == friend.id }
    }
    
    private func removeManualMember(_ member: ManualMember) {
        manualMembers.removeAll { $0.id == member.id }
    }
}

struct PreferencesView: View {
    @Binding var userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Preferences")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Times")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    if let timeSlots = userPreferences.availability[day], !timeSlots.isEmpty {
                        HStack {
                            Text(day.fullName)
                                .frame(width: 100, alignment: .leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(timeSlots, id: \.self) { slot in
                                        Text(formatTimeSlot(slot))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Days")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                FlowLayout(spacing: 8) {
                    ForEach(Array(userPreferences.preferredDays), id: \.self) { day in
                        Text(day.shortName)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Favorite Cuisines")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                FlowLayout(spacing: 8) {
                    ForEach(Array(userPreferences.favoriteCuisines), id: \.self) { cuisine in
                        HStack {
                            Text(cuisine.emoji)
                            Text(cuisine.rawValue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                }
            }
            
            Button(action: {
                // Action to edit preferences
            }) {
                Text("Edit Preferences")
                    .fontWeight(.medium)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
    
    private func formatTimeSlot(_ slot: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: slot.lowerBound)) - \(formatter.string(from: slot.upperBound))"
    }
}

struct SummaryView: View {
    let selectedFriends: [Friend]
    let manualMembers: [ManualMember]
    let userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Event Summary")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Members:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(selectedFriends) { friend in
                    Text("• \(friend.name)")
                }
                
                ForEach(manualMembers) { member in
                    Text("• \(member.name)")
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Group Preferences:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Available Times: \(availableTimesString)")
                Text("Preferred Days: \(preferredDaysString)")
                Text("Favorite Cuisines: \(favoriteCuisinesString)")
            }
        }
    }
    
    private var availableTimesString: String {
        userPreferences.availability.map { day, slots in
            "\(day.shortName): \(slots.count) slot(s)"
        }.joined(separator: ", ")
    }
    
    private var preferredDaysString: String {
        userPreferences.preferredDays.map { $0.shortName }.joined(separator: ", ")
    }
    
    private var favoriteCuisinesString: String {
        userPreferences.favoriteCuisines.map { $0.rawValue }.joined(separator: ", ")
    }
}

struct FriendsListView: View {
    @Binding var selectedFriends: [Friend]
    let maxSelection: Int
    @Environment(\.presentationMode) var presentationMode
    
    let friends = [
        Friend(name: "Alice", foodPreference: "Italian", mutualFriends: 5, favoriteRestaurant: "Pasta Palace"),
        Friend(name: "Bob", foodPreference: "Japanese", mutualFriends: 3, favoriteRestaurant: "Sushi World"),
        Friend(name: "Charlie", foodPreference: "Mexican", mutualFriends: 7, favoriteRestaurant: "Taco Town"),
        // Add more sample friends as needed
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(friends) { friend in
                    HStack {
                        Text(friend.name)
                        Spacer()
                        if selectedFriends.contains(where: { $0.id == friend.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleFriendSelection(friend)
                    }
                }
            }
            .navigationBarTitle("Select Friends", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func toggleFriendSelection(_ friend: Friend) {
        if let index = selectedFriends.firstIndex(where: { $0.id == friend.id }) {
            selectedFriends.remove(at: index)
        } else if selectedFriends.count < maxSelection {
            selectedFriends.append(friend)
        }
    }
}

struct ManualMemberEntryView: View {
    @Binding var manualMembers: [ManualMember]
    let maxMembers: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button(action: addMember) {
                        Text("Add Member")
                    }
                    .disabled(name.isEmpty || email.isEmpty || manualMembers.count >= maxMembers)
                }
            }
            .navigationBarTitle("Add Member", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addMember() {
        let newMember = ManualMember(name: name, email: email)
        manualMembers.append(newMember)
                name = ""
                email = ""
            }
        }

        struct RestaurantsFoundView: View {
            @Environment(\.presentationMode) var presentationMode
            
            let restaurants = [
                Restaurant(name: "La Bella Italia", cuisine: "Italian", rating: 4.5, price: "$$"),
                Restaurant(name: "Sushi Haven", cuisine: "Japanese", rating: 4.8, price: "$$$"),
                Restaurant(name: "Taco Fiesta", cuisine: "Mexican", rating: 4.2, price: "$"),
                Restaurant(name: "Le Petit Bistro", cuisine: "French", rating: 4.6, price: "$$$"),
                Restaurant(name: "Spice Garden", cuisine: "Indian", rating: 4.4, price: "$$"),
            ]
            
            var body: some View {
                NavigationView {
                    List(restaurants) { restaurant in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(restaurant.name)
                                .font(.headline)
                            HStack {
                                Text(restaurant.cuisine)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(restaurant.price)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(restaurant.rating) ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                }
                                Text(String(format: "%.1f", restaurant.rating))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .navigationBarTitle("Restaurants Found", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    })
                }
            }
        }

        struct ManualMember: Identifiable {
            let id = UUID()
            let name: String
            let email: String
        }

        struct UserPreferences {
            var availability: [DayOfWeek: [ClosedRange<Date>]] = [:]
            var preferredDays: Set<DayOfWeek> = []
            var favoriteCuisines: Set<CuisineType> = []
        }

        struct Restaurant: Identifiable {
            let id = UUID()
            let name: String
            let cuisine: String
            let rating: Double
            let price: String
        }

        struct AddEventView_Previews: PreviewProvider {
            static var previews: some View {
                AddEventView()
            }
        }
