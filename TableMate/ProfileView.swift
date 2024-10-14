import SwiftUI

struct ProfileView: View {
    @State private var user = User.sampleUser
    @State private var isEditingAvailability = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                profileHeader
                availabilitySection
                preferredDaysSection
                favoriteCuisinesSection
                preferencesSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $isEditingAvailability) {
            AvailabilityEditView(availability: $user.availability)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            Text(user.name)
                .font(.system(size: 24, weight: .bold, design: .serif))
            
            Text(user.tag)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
        }
    }
    
    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("My Availability")
                    .font(.headline)
                Spacer()
                Button("See All") {
                    isEditingAvailability = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            
            ForEach(DayOfWeek.allCases.prefix(3), id: \.self) { day in
                if let timeSlots = user.availability[day], !timeSlots.isEmpty {
                    HStack {
                        Text(day.fullName)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .frame(width: 100, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(timeSlots, id: \.self) { slot in
                                    TimeSlotPill(slot: slot)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var preferredDaysSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferred Days")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    Button(action: {
                        if user.preferredDays.contains(day) {
                            user.preferredDays.remove(day)
                        } else {
                            user.preferredDays.insert(day)
                        }
                    }) {
                        DayPill(day: day, isSelected: user.preferredDays.contains(day))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var favoriteCuisinesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Favorite Cuisines")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(CuisineType.allCases, id: \.self) { cuisine in
                    Button(action: {
                        if user.favoriteCuisines.contains(cuisine) {
                            user.favoriteCuisines.remove(cuisine)
                        } else {
                            user.favoriteCuisines.insert(cuisine)
                        }
                    }) {
                        CuisinePill(cuisine: cuisine, isSelected: user.favoriteCuisines.contains(cuisine))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferences")
                .font(.headline)
            
            Toggle("Open to meeting new people", isOn: $user.isOpenToMeetingNewPeople)
                .font(.system(size: 16, design: .rounded))
            
            Toggle("Notify me about new events", isOn: $user.notifyAboutNewEvents)
                .font(.system(size: 16, design: .rounded))
            
            HStack {
                Text("Preferred group size:")
                    .font(.system(size: 16, design: .rounded))
                Spacer()
                StepperView(value: $user.preferredGroupSize, range: 2...10)
            }
            
            HStack {
                Text("Max travel distance:")
                    .font(.system(size: 16, design: .rounded))
                Spacer()
                StepperView(value: $user.maxTravelDistance, range: 1...50, unit: "miles")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct TimeSlotPill: View {
    let slot: ClosedRange<Date>
    
    var body: some View {
        Text(formatTimeSlot(slot))
            .font(.system(size: 14, design: .rounded))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(15)
    }
    
    private func formatTimeSlot(_ slot: ClosedRange<Date>) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: slot.lowerBound)) - \(formatter.string(from: slot.upperBound))"
    }
}

struct DayPill: View {
    let day: DayOfWeek
    let isSelected: Bool
    
    var body: some View {
        Text(day.shortName)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
    }
}

struct CuisinePill: View {
    let cuisine: CuisineType
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(cuisine.emoji)
            Text(cuisine.rawValue)
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(15)
    }
}

struct StepperView: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var unit: String = ""
    
    var body: some View {
        HStack {
            Button(action: { if value > range.lowerBound { value -= 1 } }) {
                Image(systemName: "minus")
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
            
            Text("\(value)\(unit.isEmpty ? "" : " \(unit)")")
                .frame(minWidth: 40)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            
            Button(action: { if value < range.upperBound { value += 1 } }) {
                Image(systemName: "plus")
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.height }.max() ?? 0 }.reduce(0, +) + CGFloat(rows.count - 1) * spacing
        return CGSize(width: proposal.width ?? .zero, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        var yOffset: CGFloat = 0
        for row in rows {
            var xOffset: CGFloat = 0
            for column in row {
                let subview = subviews[column.index]
                subview.place(at: CGPoint(x: bounds.minX + xOffset, y: bounds.minY + yOffset), proposal: .unspecified)
                xOffset += column.width + spacing
            }
            yOffset += (row.map { $0.height }.max() ?? 0) + spacing
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [[ColumnData]] {
        guard let maxWidth = proposal.width else { return [] }
        var rows: [[ColumnData]] = [[]]
        var currentX: CGFloat = 0
        var currentRow = 0
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, !rows[currentRow].isEmpty {
                currentRow += 1
                rows.append([])
                currentX = 0
            }
            rows[currentRow].append(ColumnData(index: index, width: size.width, height: size.height))
            currentX += size.width + spacing
        }
        return rows
    }
    
    struct ColumnData {
        let index: Int
        let width: CGFloat
        let height: CGFloat
    }
}

struct AvailabilityEditView: View {
    @Binding var availability: [DayOfWeek: [ClosedRange<Date>]]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(DayOfWeek.allCases, id: \.self) { day in
                    Section(header: Text(day.fullName)) {
                        ForEach(availability[day] ?? [], id: \.self) { slot in
                            TimeSlotEditor(slot: slot) { newSlot in
                                if let index = availability[day]?.firstIndex(of: slot) {
                                    availability[day]?[index] = newSlot
                                }
                            }
                        }
                        .onDelete { indexSet in
                            availability[day]?.remove(atOffsets: indexSet)
                        }
                        
                        Button(action: {
                            let newSlot = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!...Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date())!
                            availability[day, default: []].append(newSlot)
                        }) {
                            Label("Add Time Slot", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationBarTitle("Edit Availability", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct TimeSlotEditor: View {
    let slot: ClosedRange<Date>
    let onEdit: (ClosedRange<Date>) -> Void
    @State private var startTime: Date
    @State private var endTime: Date
    
    init(slot: ClosedRange<Date>, onEdit: @escaping (ClosedRange<Date>) -> Void) {
        self.slot = slot
        self.onEdit = onEdit
        _startTime = State(initialValue: slot.lowerBound)
        _endTime = State(initialValue: slot.upperBound)
    }
    
    var body: some View {
        HStack {
            DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
            DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
        }
        .onChange(of: startTime) { _ in updateSlot() }
        .onChange(of: endTime) { _ in updateSlot() }
    }
    
    private func updateSlot() {
        onEdit(startTime...endTime)
    }
}

enum DayOfWeek: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var fullName: String {
        self.rawValue.capitalized
    }
    
    var shortName: String {
        String(self.rawValue.prefix(3).capitalized)
    }
}

enum CuisineType: String, CaseIterable {
    case italian = "Italian"
    case japanese = "Japanese"
    case mexican = "Mexican"
    case indian = "Indian"
    case chinese = "Chinese"
    case french = "French"
    case american = "American"
    case mediterranean = "Mediterranean"
    case thai = "Thai"
    case vietnamese = "Vietnamese"
    
    var emoji: String {
        switch self {
        case .italian: return "🍝"
        case .japanese: return "🍣"
        case .mexican: return "🌮"
        case .indian: return "🍛"
        case .chinese: return "🥡"
        case .french: return "🥐"
        case .american: return "🍔"
       case .mediterranean: return "🥙"
        case .thai: return "🍜"
        case .vietnamese: return "🍲"
        }
    }
}

struct User {
    var name: String
    var tag: String
    var availability: [DayOfWeek: [ClosedRange<Date>]]
    var preferredDays: Set<DayOfWeek>
    var favoriteCuisines: Set<CuisineType>
    var isOpenToMeetingNewPeople: Bool
    var notifyAboutNewEvents: Bool
    var preferredGroupSize: Int
    var maxTravelDistance: Int
    
    static var sampleUser: User {
        User(
            name: "Alice Johnson",
            tag: "Foodie Explorer",
            availability: [
                .monday: [Date.parse("12:00")...Date.parse("14:00")],
                .wednesday: [Date.parse("18:00")...Date.parse("21:00")],
                .friday: [Date.parse("19:00")...Date.parse("22:00")],
                .saturday: [Date.parse("11:00")...Date.parse("15:00"), Date.parse("18:00")...Date.parse("22:00")]
            ],
            preferredDays: [.friday, .saturday, .sunday],
            favoriteCuisines: [.italian, .japanese, .mexican],
            isOpenToMeetingNewPeople: true,
            notifyAboutNewEvents: true,
            preferredGroupSize: 4,
            maxTravelDistance: 10
        )
    }
}

extension Date {
    static func parse(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: string) ?? Date()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
