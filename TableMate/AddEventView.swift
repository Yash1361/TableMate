import SwiftUI

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    @State private var groupSize = 3
    @State private var selectedFriends: [Friend] = []
    @State private var manualMembers: [ManualMember] = []
    @State private var showingSummary = false
    @State private var userPreferences: UserPreferences
    @State private var showingRestaurants = false
    
    let steps = ["Group Size", "Add Members", "Preferences", "Summary"]
    
    init() {
        let user = User.sampleUser
        _userPreferences = State(initialValue: UserPreferences(
            availability: user.availability,
            preferredDays: user.preferredDays,
            favoriteCuisines: user.favoriteCuisines
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                StepProgressView(currentStep: $currentStep, steps: steps)
                    .padding(.top)
                
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
                            EnhancedSummaryView(selectedFriends: selectedFriends, manualMembers: $manualMembers, userPreferences: userPreferences)
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
                    if manualMembers.allSatisfy({ $0.isComplete }) {
                        showingRestaurants = true
                    }
                }) {
                    Text("Find Restaurants")
                        .fontWeight(.medium)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!manualMembers.allSatisfy({ $0.isComplete }))
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
        VStack(spacing: 24) {
            Text("How many people are joining?")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(2...6, id: \.self) { size in
                    GroupSizeButton(size: size, isSelected: groupSize == size) {
                        groupSize = size
                    }
                }
            }
            
            Text("Selected group size: \(groupSize)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct GroupSizeButton: View {
    let size: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("\(size)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(isSelected ? .white : .primary)
                }
                
                Text(size == 2 ? "Couple" : "\(size) People")
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .secondary)
            }
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
        VStack(alignment: .leading, spacing: 20) {
            Text("Add up to \(groupSize) members")
                .font(.headline)
            
            HStack(spacing: 16) {
                Button(action: { showingFriendsList = true }) {
                    VStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 24))
                        Text("Add Friends")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                }
                
                Button(action: { showingManualEntry = true }) {
                    VStack {
                        Image(systemName: "person.fill.badge.plus")
                            .font(.system(size: 24))
                        Text("Add Manually")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(12)
                }
            }
            
            if !selectedFriends.isEmpty {
                Text("Selected Friends:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(selectedFriends) { friend in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.blue)
                        Text(friend.name)
                        Spacer()
                        Button(action: { removeFriend(friend) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if !manualMembers.isEmpty {
                Text("Manually Added Members:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(manualMembers) { member in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.green)
                        Text(member.name)
                        Spacer()
                        Button(action: { removeManualMember(member) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showingFriendsList) {
            EnhancedFriendsListView(selectedFriends: $selectedFriends, maxSelection: groupSize - manualMembers.count)
        }
        .sheet(isPresented: $showingManualEntry) {
            EnhancedManualMemberEntryView(manualMembers: $manualMembers, maxMembers: groupSize - selectedFriends.count)
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
    @State private var showingEditView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Preferences")
                .font(.headline)
            
            PreferencesSummaryView(preferences: userPreferences)
            
            Button(action: { showingEditView = true }) {
                Text("Edit Preferences")
                    .fontWeight(.medium)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .sheet(isPresented: $showingEditView) {
            EditPreferencesView(preferences: $userPreferences)
        }
    }
}

struct PreferencesSummaryView: View {
    let preferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            PreferencesSection(title: "Available Times") {
                availableTimesView
            }
            PreferencesSection(title: "Preferred Days") {
                preferredDaysView
            }
            PreferencesSection(title: "Favorite Cuisines") {
                favoriteCuisinesView
            }
        }
    }
    
    private var availableTimesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(DayOfWeek.allCases, id: \.self) { day in
                if let timeSlots = preferences.availability[day], !timeSlots.isEmpty {
                    HStack {
                        Text(day.shortName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(width: 40, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(timeSlots, id: \.self) { slot in
                                    Text(formatTimeSlot(slot))
                                        .font(.caption)
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
    }
    
    private var preferredDaysView: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(preferences.preferredDays), id: \.self) { day in
                Text(day.shortName)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(15)
            }
        }
    }
    
    private var favoriteCuisinesView: some View {
        FlowLayout(spacing: 8) {
            ForEach(Array(preferences.favoriteCuisines), id: \.self) { cuisine in
                HStack {
                    Text(cuisine.emoji)
                    Text(cuisine.rawValue)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(15)
            }
        }
    }
    
    private func formatTimeSlot(_ slot: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: slot.lowerBound)) - \(formatter.string(from: slot.upperBound))"
    }
}

struct PreferencesSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            content
        }
    }
}

struct EditPreferencesView: View {
    @Binding var preferences: UserPreferences
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Available Times")) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        NavigationLink(destination: DayAvailabilityView(availability: Binding(
                            get: { preferences.availability[day] ?? [] },
                            set: { preferences.availability[day] = $0 }
                        ))) {
                            Text(day.fullName)
                        }
                    }
                }
                
                Section(header: Text("Preferred Days")) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Toggle(day.fullName, isOn: Binding(
                            get: { preferences.preferredDays.contains(day) },
                            set: { isOn in
                                if isOn {
                                    preferences.preferredDays.insert(day)
                                } else {
                                    preferences.preferredDays.remove(day)
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Favorite Cuisines")) {
                    ForEach(CuisineType.allCases, id: \.self) { cuisine in
                        Toggle(cuisine.rawValue, isOn: Binding(
                            get: { preferences.favoriteCuisines.contains(cuisine) },
                            set: { isOn in
                                if isOn {
                                    preferences.favoriteCuisines.insert(cuisine)
                                } else {
                                    preferences.favoriteCuisines.remove(cuisine)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationBarTitle("Edit Preferences", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct DayAvailabilityView: View {
    @Binding var availability: [ClosedRange<Date>]
    @State private var newStartTime = Date()
    @State private var newEndTime = Date().addingTimeInterval(3600)
    
    var body: some View {
        List {
            ForEach(availability, id: \.self) { slot in
                HStack {
                    Text(formatTimeSlot(slot))
                    Spacer()
                    Button(action: {
                        availability.removeAll { $0 == slot }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .onDelete(perform: deleteSlots)
            
            Section(header: Text("Add New Time Slot")) {
                DatePicker("Start", selection: $newStartTime, displayedComponents: .hourAndMinute)
                DatePicker("End", selection: $newEndTime, displayedComponents: .hourAndMinute)
                
                Button("Add Time Slot") {
                    let newSlot = newStartTime...newEndTime
                    availability.append(newSlot)
                    newStartTime = Date()
                    newEndTime = Date().addingTimeInterval(3600)
                }
            }
        }
        .navigationBarTitle("Edit Availability", displayMode: .inline)
    }
    
    private func deleteSlots(at offsets: IndexSet) {
        availability.remove(atOffsets: offsets)
    }
    
    private func formatTimeSlot(_ slot: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: slot.lowerBound)) - \(formatter.string(from: slot.upperBound))"
    }
}

struct EnhancedSummaryView: View {
    let selectedFriends: [Friend]
    @Binding var manualMembers: [ManualMember]
    let userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Event Summary")
                .font(.headline)
            
            GroupMembersSummary(selectedFriends: selectedFriends, manualMembers: manualMembers)
            
            UserPreferencesSummary(preferences: userPreferences)
            
            if !manualMembers.isEmpty {
                ManualMembersSummary(manualMembers: $manualMembers)
            }
        }
    }
}

struct GroupMembersSummary: View {
    let selectedFriends: [Friend]
    let manualMembers: [ManualMember]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Members")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(selectedFriends) { friend in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text(friend.name)
                    Spacer()
                    Text("From Friends List")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(manualMembers) { member in
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.green)
                    Text(member.name)
                    Spacer()
                    Text("Added Manually")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct UserPreferencesSummary: View {
    let preferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Preferences")
                .font(.title3)
                .fontWeight(.bold)
            
            PreferencesSummaryView(preferences: preferences)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ManualMembersSummary: View {
    @Binding var manualMembers: [ManualMember]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Manual Members Details")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach($manualMembers) { $member in
                ManualMemberDetailView(member: $member)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ManualMemberDetailView: View {
    @Binding var member: ManualMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(member.name)
                .font(.headline)
            
            PreferencesSection(title: "Available Times") {
                if member.availability.isEmpty {
                    Text("No times set")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        if let slots = member.availability[day], !slots.isEmpty {
                            HStack {
                                Text(day.shortName)
                                    .font(.caption)
                                    .frame(width: 30, alignment: .leading)
                                ForEach(slots, id: \.self) { slot in
                                    Text(formatTimeSlot(slot))
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }
            
            PreferencesSection(title: "Preferred Days") {
                if member.preferredDays.isEmpty {
                    Text("No preferred days set")
                        .foregroundColor(.secondary)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(member.preferredDays), id: \.self) { day in
                            Text(day.shortName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            PreferencesSection(title: "Favorite Cuisines") {
                if member.favoriteCuisines.isEmpty {
                    Text("No favorite cuisines set")
                        .foregroundColor(.secondary)
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(Array(member.favoriteCuisines), id: \.self) { cuisine in
                            HStack {
                                Text(cuisine.emoji)
                                Text(cuisine.rawValue)
                            }
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            Button(action: {
                // Show edit view for this manual member
            }) {
                Text("Edit Details")
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatTimeSlot(_ slot: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: slot.lowerBound)) - \(formatter.string(from: slot.upperBound))"
    }
}

struct EnhancedFriendsListView: View {
    @Binding var selectedFriends: [Friend]
    let maxSelection: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    let friends = [
        Friend(name: "Alice", foodPreference: "Italian", mutualFriends: 5, favoriteRestaurant: "Pasta Palace"),
        Friend(name: "Bob", foodPreference: "Japanese", mutualFriends: 3, favoriteRestaurant: "Sushi World"),
        Friend(name: "Charlie", foodPreference: "Mexican", mutualFriends: 7, favoriteRestaurant: "Taco Town"),
        Friend(name: "David", foodPreference: "Indian", mutualFriends: 2, favoriteRestaurant: "Spice Garden"),
        Friend(name: "Eva", foodPreference: "Chinese", mutualFriends: 4, favoriteRestaurant: "Dragon Palace"),
    ]
    
    var filteredFriends: [Friend] {
        if searchText.isEmpty {
            return friends
        } else {
            return friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Search friends")
                
                List {
                    ForEach(filteredFriends) { friend in
                        FriendRow(friend: friend, isSelected: selectedFriends.contains { $0.id == friend.id })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleFriendSelection(friend)
                            }
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

struct FriendRow: View {
    let friend: Friend
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)
                Text(friend.foodPreference)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
            }
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct EnhancedManualMemberEntryView: View {
    @Binding var manualMembers: [ManualMember]
    let maxMembers: Int
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var showingPreferencesEntry = false
    @State private var currentMember: ManualMember?
    
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
                
                if !manualMembers.isEmpty {
                    Section(header: Text("Added Members")) {
                        ForEach(manualMembers) { member in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(member.name)
                                    Text(member.email)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    currentMember = member
                                    showingPreferencesEntry = true
                                }) {
                                    Text("Edit Preferences")
                                        .font(.footnote)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                        .onDelete(perform: deleteMembers)
                    }
                }
            }
            .navigationBarTitle("Add Member", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .sheet(isPresented: $showingPreferencesEntry) {
            if let member = currentMember {
                ManualMemberPreferencesView(member: binding(for: member))
            }
        }
    }
    
    private func addMember() {
        let newMember = ManualMember(name: name, email: email)
        manualMembers.append(newMember)
        name = ""
        email = ""
    }
    
    private func deleteMembers(at offsets: IndexSet) {
        manualMembers.remove(atOffsets: offsets)
    }
    
    private func binding(for member: ManualMember) -> Binding<ManualMember> {
        guard let index = manualMembers.firstIndex(where: { $0.id == member.id }) else {
            fatalError("Member not found")
        }
        return $manualMembers[index]
    }
}

struct ManualMemberPreferencesView: View {
    @Binding var member: ManualMember
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Available Times")) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        NavigationLink(destination: DayAvailabilityView(availability: bindingForAvailability(day: day))) {
                            Text(day.fullName)
                        }
                    }
                }
                
                Section(header: Text("Preferred Days")) {
                    ForEach(DayOfWeek.allCases, id: \.self) { day in
                        Toggle(day.fullName, isOn: bindingForPreferredDay(day: day))
                    }
                }
                
                Section(header: Text("Favorite Cuisines")) {
                    ForEach(CuisineType.allCases, id: \.self) { cuisine in
                        Toggle(cuisine.rawValue, isOn: bindingForCuisine(cuisine: cuisine))
                    }
                }
            }
            .navigationBarTitle("\(member.name)'s Preferences", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func bindingForAvailability(day: DayOfWeek) -> Binding<[ClosedRange<Date>]> {
        Binding(
            get: { member.availability[day] ?? [] },
            set: { member.availability[day] = $0 }
        )
    }
    
    private func bindingForPreferredDay(day: DayOfWeek) -> Binding<Bool> {
        Binding(
            get: { member.preferredDays.contains(day) },
            set: { isOn in
                if isOn {
                    member.preferredDays.insert(day)
                } else {
                    member.preferredDays.remove(day)
                }
            }
        )
    }
    
    private func bindingForCuisine(cuisine: CuisineType) -> Binding<Bool> {
        Binding(
            get: { member.favoriteCuisines.contains(cuisine) },
            set: { isOn in
                if isOn {
                    member.favoriteCuisines.insert(cuisine)
                } else {
                    member.favoriteCuisines.remove(cuisine)
                }
            }
        )
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
            List {
                ForEach(restaurants) { restaurant in
                    RestaurantRow(restaurant: restaurant)
                }
            }
            .navigationBarTitle("Restaurants Found", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct RestaurantRow: View {
    let restaurant: Restaurant
    
    var body: some View {
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
        .padding(.vertical, 8)
    }
}

struct ManualMember: Identifiable {
    let id = UUID()
    var name: String
    var email: String
    var availability: [DayOfWeek: [ClosedRange<Date>]] = [:]
    var preferredDays: Set<DayOfWeek> = []
    var favoriteCuisines: Set<CuisineType> = []
    
    var isComplete: Bool {
        !availability.isEmpty && !preferredDays.isEmpty && !favoriteCuisines.isEmpty
    }
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
