import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ToolCategory?
    @State private var priceRange: ClosedRange<Float> = 0...100
    @State private var showFilters = false
    
    let categories: [ToolCategory] = [.powerTools, .handTools, .gardenTools, .automotive, .homeImprovement]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchHeader
                
                if showFilters {
                    filterView
                }
                
                Divider()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(0..<20) { _ in
                            ToolCardView()
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search for tools...", text: $searchText)
                    .font(.system(size: 17, weight: .regular, design: .serif))
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            HStack {
                Button(action: { showFilters.toggle() }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(showFilters ? "Hide Filters" : "Show Filters")
                    }
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                Menu {
                    Button("Price: Low to High", action: { /* Sort action */ })
                    Button("Price: High to Low", action: { /* Sort action */ })
                    Button("Distance: Nearest", action: { /* Sort action */ })
                    Button("Rating: Highest", action: { /* Sort action */ })
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    private var filterView: some View {
        VStack(spacing: 16) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryPill(category: category, isSelected: selectedCategory == category) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Price Range")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                
                HStack {
                    Text("$\(Int(priceRange.lowerBound))")
                    Spacer()
                    Text("$\(Int(priceRange.upperBound))")
                }
                .font(.system(size: 13, weight: .regular, design: .serif))
                
                CustomSlider(value: $priceRange, in: 0...500)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}

struct ToolCardView: View {
    let id = UUID()
    
    var body: some View {
        HStack(spacing: 16) {
            RemoteImage(url: "https://picsum.photos/150", id: id)
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Professional Drill")
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                
                Text("Power Tools")
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$15/day")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("4.8")
                            .font(.system(size: 14, weight: .medium, design: .serif))
                    }
                }
                
                Text("2.5 miles away")
                    .font(.system(size: 13, weight: .regular, design: .serif))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct CategoryPill: View {
    let category: ToolCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct CustomSlider: View {
    @Binding var value: ClosedRange<Float>
    let bounds: ClosedRange<Float>
    
    init(value: Binding<ClosedRange<Float>>, in bounds: ClosedRange<Float>) {
        self._value = value
        self.bounds = bounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray4))
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: self.getWidth(from: geometry.size.width))
            }
            .frame(height: 4)
            .cornerRadius(2)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    self.updateValue(at: value.location, in: geometry.size)
                }
            )
            
            self.lowerThumb(in: geometry.size)
            self.upperThumb(in: geometry.size)
        }
        .frame(height: 30)
    }
    
    private func lowerThumb(in size: CGSize) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 28, height: 28)
            .shadow(radius: 2)
            .position(x: self.getPosition(for: self.value.lowerBound, in: size), y: size.height / 2)
    }
    
    private func upperThumb(in size: CGSize) -> some View {
        Circle()
            .fill(Color.white)
            .frame(width: 28, height: 28)
            .shadow(radius: 2)
            .position(x: self.getPosition(for: self.value.upperBound, in: size), y: size.height / 2)
    }
    
    private func getWidth(from totalWidth: CGFloat) -> CGFloat {
        let lowerX = CGFloat((value.lowerBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * totalWidth
        let upperX = CGFloat((value.upperBound - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * totalWidth
        return upperX - lowerX
    }
    
    private func getPosition(for value: Float, in size: CGSize) -> CGFloat {
        CGFloat((value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)) * size.width
    }
    
    private func updateValue(at point: CGPoint, in size: CGSize) {
        let percentage = max(0, min(1, point.x / size.width))
        let newValue = Float(percentage) * (bounds.upperBound - bounds.lowerBound) + bounds.lowerBound
        
        if abs(CGFloat(newValue - value.lowerBound)) < abs(CGFloat(newValue - value.upperBound)) {
            value = newValue...value.upperBound
        } else {
            value = value.lowerBound...newValue
        }
    }
}

enum ToolCategory: String, CaseIterable {
    case powerTools = "Power Tools"
    case handTools = "Hand Tools"
    case gardenTools = "Garden Tools"
    case automotive = "Automotive"
    case homeImprovement = "Home Improvement"
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
