import SwiftUI
import Charts

struct ProfileView: View {
    @State private var selectedEarningsTimeFrame: TimeFrame = .month
    @State private var selectedSpendingsTimeFrame: TimeFrame = .month
    @State private var isEditingProfile = false
    @State private var showingSettings = false
    
    // Mock data
    let user = User(name: "John Doe", email: "john.doe@example.com", joinDate: Date().addingTimeInterval(-365*24*60*60), rating: 4.8)
    let earnings = [
        Earning(date: Date().addingTimeInterval(-6*30*24*60*60), amount: 120),
        Earning(date: Date().addingTimeInterval(-5*30*24*60*60), amount: 180),
        Earning(date: Date().addingTimeInterval(-4*30*24*60*60), amount: 250),
        Earning(date: Date().addingTimeInterval(-3*30*24*60*60), amount: 200),
        Earning(date: Date().addingTimeInterval(-2*30*24*60*60), amount: 300),
        Earning(date: Date().addingTimeInterval(-1*30*24*60*60), amount: 280)
    ]
    let spendings = [
        Earning(date: Date().addingTimeInterval(-6*30*24*60*60), amount: 100),
        Earning(date: Date().addingTimeInterval(-5*30*24*60*60), amount: 150),
        Earning(date: Date().addingTimeInterval(-4*30*24*60*60), amount: 180),
        Earning(date: Date().addingTimeInterval(-3*30*24*60*60), amount: 170),
        Earning(date: Date().addingTimeInterval(-2*30*24*60*60), amount: 220),
        Earning(date: Date().addingTimeInterval(-1*30*24*60*60), amount: 200)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    headerSection
                    statsSection
                    earningsSection
                    spendingsSection
                    activitySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(user: user)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            RemoteImage(url: "https://picsum.photos/200", id: UUID())
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10)
            
            VStack(spacing: 8) {
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(user.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                    Text(String(format: "%.1f", user.rating))
                        .fontWeight(.medium)
                }
                .font(.footnote)
                
                Text("Member since \(user.joinDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: { isEditingProfile = true }) {
                Text("Edit Profile")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue)
                    .cornerRadius(25)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var statsSection: some View {
        HStack(spacing: 15) {
            StatCard(title: "Tools", value: "12", icon: "wrench.fill", color: .blue)
            StatCard(title: "Rentals", value: "28", icon: "cart.fill", color: .green)
            StatCard(title: "Reviews", value: "47", icon: "star.fill", color: .yellow)
        }
    }
    
    private var earningsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Earnings")
                .font(.title3)
                .fontWeight(.semibold)
            
            Picker("Time Frame", selection: $selectedEarningsTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Chart {
                ForEach(earnings) { earning in
                    BarMark(
                        x: .value("Month", earning.date, unit: .month),
                        y: .value("Amount", earning.amount)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
            }
            .frame(height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Earnings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(earnings.map { $0.amount }.reduce(0, +))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg. per \(selectedEarningsTimeFrame.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(earnings.map { $0.amount }.reduce(0, +) / earnings.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var spendingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Spendings")
                .font(.title3)
                .fontWeight(.semibold)
            
            Picker("Time Frame", selection: $selectedSpendingsTimeFrame) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Chart {
                ForEach(spendings) { spending in
                    BarMark(
                        x: .value("Month", spending.date, unit: .month),
                        y: .value("Amount", spending.amount)
                    )
                    .foregroundStyle(Color.red.gradient)
                }
            }
            .frame(height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Spendings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(spendings.map { $0.amount }.reduce(0, +))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Avg. per \(selectedSpendingsTimeFrame.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(spendings.map { $0.amount }.reduce(0, +) / spendings.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recent Activity")
                .font(.title3)
                .fontWeight(.semibold)
            
            ForEach(0..<3) { _ in
                ActivityRow()
            }
            
            Button(action: {}) {
                Text("View All Activity")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ActivityRow: View {
    var body: some View {
        HStack(spacing: 15) {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "wrench.fill")
                        .foregroundColor(.blue)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text("Rented out Power Drill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("2 days ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("$25")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 10)
    }
}

struct EditProfileView: View {
    let user: User
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: .constant(user.name))
                    TextField("Email", text: .constant(user.email))
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Email Notifications", isOn: .constant(true))
                    Toggle("Push Notifications", isOn: .constant(true))
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Show Profile to Public", isOn: .constant(true))
                    Toggle("Show Earnings", isOn: .constant(false))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    NavigationLink("Change Password", destination: Text("Change Password View"))
                    NavigationLink("Linked Accounts", destination: Text("Linked Accounts View"))
                }
                
                Section(header: Text("Preferences")) {
                    NavigationLink("Language", destination: Text("Language Selection View"))
                    NavigationLink("Currency", destination: Text("Currency Selection View"))
                }
                
                Section(header: Text("Support")) {
                    NavigationLink("Help Center", destination: Text("Help Center View"))
                    NavigationLink("Contact Us", destination: Text("Contact Us View"))
                }
                
                Section {
                    Button("Log Out") {
                        // Perform logout action
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Data Models and Helper Enums
struct User {
    let name: String
    let email: String
    let joinDate: Date
    let rating: Double
}

struct Earning: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Int
}

enum TimeFrame: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

// Preview Provider
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
