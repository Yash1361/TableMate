import SwiftUI

struct BookingsView: View {
    @State private var selectedSegment = 0
    @State private var searchText = ""
    @State private var isFilterPresented = false
    @State private var selectedFilter = "All"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                CustomSegmentedControl(selection: $selectedSegment)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Filter button
                HStack {
                    Spacer()
                    Button(action: { isFilterPresented = true }) {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 8)
                
                ScrollView {
                    if selectedSegment == 0 {
                        RentalsView(searchText: searchText, filter: selectedFilter)
                    } else {
                        LendingsView(searchText: searchText, filter: selectedFilter)
                    }
                }
                .refreshable {
                    // Add refresh functionality here
                }
            }
            .navigationTitle("Your Bookings")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isFilterPresented) {
                FilterView(selectedFilter: $selectedFilter)
            }
        }
    }
}

struct CustomSegmentedControl: View {
    @Binding var selection: Int
    let options = ["Rentals", "Lendings"]
    
    var body: some View {
        HStack {
            ForEach(options.indices, id: \.self) { index in
                Button(action: { selection = index }) {
                    Text(options[index])
                        .fontWeight(selection == index ? .bold : .regular)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selection == index ? Color.blue : Color.clear)
                        )
                }
                .foregroundColor(selection == index ? .white : .blue)
            }
        }
        .background(Color.blue.opacity(0.1))
        .cornerRadius(20)
    }
}

struct FilterView: View {
    @Binding var selectedFilter: String
    @Environment(\.presentationMode) var presentationMode
    
    let filters = ["All", "Due This Week", "Overdue", "Active", "Completed"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filters, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(filter)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct RentalsView: View {
    let searchText: String
    let filter: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Due This Week")
            RentalsList(dueThisWeek: true, searchText: searchText, filter: filter)
            
            SectionHeaderView(title: "Due Later")
            RentalsList(dueThisWeek: false, searchText: searchText, filter: filter)
        }
        .padding(.horizontal)
    }
}

struct LendingsView: View {
    let searchText: String
    let filter: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: "Currently Lent Out")
            LendingsList(taken: true, searchText: searchText, filter: filter)
            
            SectionHeaderView(title: "Available for Rent")
            LendingsList(taken: false, searchText: searchText, filter: filter)
        }
        .padding(.horizontal)
    }
}

struct RentalsList: View {
    let dueThisWeek: Bool
    let searchText: String
    let filter: String
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { _ in
                BookingRow(isRental: true, dueSoon: dueThisWeek, taken: nil)
            }
        }
    }
}

struct LendingsList: View {
    let taken: Bool
    let searchText: String
    let filter: String
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<3) { _ in
                BookingRow(isRental: false, dueSoon: nil, taken: taken)
            }
        }
    }
}

struct BookingRow: View {
    let isRental: Bool
    let dueSoon: Bool?
    let taken: Bool?
    let id = UUID()
    @State private var isShowingDetails = false
    
    var body: some View {
        Button(action: { isShowingDetails = true }) {
            HStack(spacing: 16) {
                RemoteImage(url: "https://picsum.photos/80", id: id)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Power Drill XL-2000")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isRental {
                        Label(
                            dueSoon == true ? "Due in 2 days" : "Rented from John Doe",
                            systemImage: dueSoon == true ? "exclamationmark.circle" : "person.crop.circle"
                        )
                        .font(.subheadline)
                        .foregroundColor(dueSoon == true ? .red : .secondary)
                    } else {
                        Label(
                            taken == true ? "Lent to Jane Smith" : "Available for Rent",
                            systemImage: taken == true ? "person.crop.circle" : "checkmark.circle"
                        )
                        .font(.subheadline)
                        .foregroundColor(taken == true ? .secondary : .green)
                    }
                    
                    Text("May 1 - May 5, 2023")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    Text("$40")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    ActionButton(isRental: isRental, taken: taken)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $isShowingDetails) {
            BookingDetailView(isRental: isRental, dueSoon: dueSoon, taken: taken)
        }
    }
}

struct ActionButton: View {
    let isRental: Bool
    let taken: Bool?
    
    var body: some View {
        Group {
            if isRental {
                Button(action: {}) {
                    Label("Return", systemImage: "arrow.uturn.left")
                }
                .buttonStyle(PrimaryButtonStyle())
            } else {
                if taken == true {
                    Button(action: {}) {
                        Label("Extend", systemImage: "clock")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                } else {
                    Button(action: {}) {
                        Label("Edit", systemImage: "pencil")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundColor(.blue)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct SectionHeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

struct BookingDetailView: View {
    let isRental: Bool
    let dueSoon: Bool?
    let taken: Bool?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    RemoteImage(url: "https://picsum.photos/400", id: UUID())
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Power Drill XL-2000")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label("$40 / day", systemImage: "dollarsign.circle")
                            Spacer()
                            Label("4.8 (120 reviews)", systemImage: "star.fill")
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Booking Details")
                            .font(.headline)
                        
                        DetailRow(title: "Status", value: isRental ? (dueSoon == true ? "Due Soon" : "Active") : (taken == true ? "Lent Out" : "Available"))
                        DetailRow(title: "Period", value: "May 1 - May 5, 2023")
                        DetailRow(title: isRental ? "Rented From" : "Lent To", value: isRental ? "John Doe" : (taken == true ? "Jane Smith" : "N/A"))
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tool Description")
                            .font(.headline)
                        
                        Text("The Power Drill XL-2000 is a high-performance cordless drill perfect for both DIY enthusiasts and professionals. With its powerful motor and long-lasting battery, it can handle a wide range of drilling and driving tasks.")
                            .foregroundColor(.secondary)
                    }
                    
                    if isRental || taken == true {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Actions")
                                .font(.headline)
                            
                            HStack {
                                Button(action: {}) {
                                    Label(isRental ? "Return Tool" : "Extend Rental", systemImage: isRental ? "arrow.uturn.left" : "clock")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                
                                Button(action: {}) {
                                    Label("Contact Owner", systemImage: "message")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("Booking Details", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            })
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct BookingsView_Previews: PreviewProvider {
    static var previews: some View {
        BookingsView()
    }
}
