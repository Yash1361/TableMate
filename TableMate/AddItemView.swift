import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var toolName = ""
    @State private var toolDescription = ""
    @State private var toolType: ToolType = .powerTools
    @State private var pricePerDay = ""
    @State private var availabilityDate = Date()
    @State private var condition: Condition = .excellent
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var currentStep = 0
    @State private var isLoading = false
    
    let maxSteps = 4
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                customNavigationBar
                
                ProgressBar(value: Double(currentStep) / Double(maxSteps - 1))
                    .frame(height: 4)
                    .padding(.top, 8)
                
                TabView(selection: $currentStep) {
                    basicInfoSection.tag(0)
                    detailsSection.tag(1)
                    imagesSection.tag(2)
                    summarySection.tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                navigationButtons
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImages: $selectedImages)
        }
        .alert(isPresented: $isLoading) {
            Alert(title: Text("Submitting"), message: Text("Please wait while we process your tool listing."), dismissButton: .none)
        }
    }
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
                    .padding()
            }
            
            Spacer()
            
            Text("Add New Tool")
                .font(.headline)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    if currentStep < maxSteps - 1 {
                        currentStep += 1
                    }
                }
            }) {
                Text("Next")
                    .foregroundColor(.blue)
                    .padding()
            }
            .opacity(currentStep < maxSteps - 1 ? 1 : 0)
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    private var basicInfoSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Basic Information", icon: "info.circle.fill")
                
                FloatingLabelTextField(placeholder: "Tool Name", text: $toolName, icon: "wrench.fill")
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tool Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ToolTypePicker(selectedToolType: $toolType)
                }
                
                FloatingLabelTextField(placeholder: "Price per Day", text: $pricePerDay, icon: "dollarsign.circle.fill")
                    .keyboardType(.decimalPad)
            }
            .padding()
        }
    }
    
    private var detailsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Tool Details", icon: "doc.text.fill")
                
                FloatingLabelTextEditor(placeholder: "Description", text: $toolDescription)
                    .frame(height: 150)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available From")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $availabilityDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Condition")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ConditionPicker(selectedCondition: $condition)
                }
            }
            .padding()
        }
    }
    
    private var imagesSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Tool Images", icon: "photo.fill")
                
                if selectedImages.isEmpty {
                    AddPhotosButton(action: { showingImagePicker = true })
                } else {
                    ImageGallery(images: selectedImages, onAddTap: { showingImagePicker = true })
                }
            }
            .padding()
        }
    }
    
    private var summarySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionTitle(title: "Summary", icon: "list.bullet.rectangle.fill")
                
                SummaryCard(toolName: toolName, toolType: toolType, pricePerDay: pricePerDay, description: toolDescription, availabilityDate: availabilityDate, condition: condition)
                
                if !selectedImages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Images")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                }
                
                Button(action: submitForm) {
                    Text("Submit Listing")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 24)
            }
            .padding()
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button(action: {
                    withAnimation {
                        currentStep -= 1
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            Spacer()
            
            if currentStep < maxSteps - 1 {
                Button(action: {
                    withAnimation {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
    
    private func submitForm() {
        isLoading = true
        // Simulate form submission
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.blue)
                    .animation(.linear, value: value)
            }
        }
    }
}

struct FloatingLabelTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(text.isEmpty ? .secondary : .blue)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(placeholder)
                        .font(.caption)
                        .foregroundColor(text.isEmpty ? .clear : .secondary)
                        .offset(y: text.isEmpty ? 20 : 0)
                    
                    TextField(text.isEmpty ? placeholder : "", text: $text)
                        .font(.body)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .animation(.easeInOut(duration: 0.2), value: text)
        }
    }
}

struct FloatingLabelTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $text)
                .font(.body)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

struct ToolTypePicker: View {
    @Binding var selectedToolType: ToolType
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ToolType.allCases, id: \.self) { toolType in
                    ToolTypeButton(type: toolType, isSelected: selectedToolType == toolType) {
                        selectedToolType = toolType
                    }
                }
            }
        }
    }
}

struct ToolTypeButton: View {
    let type: ToolType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                Text(type.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
            }
        }
    }
}

struct ConditionPicker: View {
    @Binding var selectedCondition: Condition
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Condition.allCases, id: \.self) { condition in
                ConditionButton(condition: condition, isSelected: selectedCondition == condition) {
                    selectedCondition = condition
                }
            }
        }
    }
}

struct ConditionButton: View {
    let condition: Condition
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(condition.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .cornerRadius(20)
        }
    }
}

struct AddPhotosButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "camera.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                Text("Add Photos")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct ImageGallery: View {
    let images: [UIImage]
    let onAddTap: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                AddPhotoButton(action: onAddTap)
            }
        }
    }
}

struct AddPhotoButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            .frame(width: 150, height: 150)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SummaryCard: View {
    let toolName: String
    let toolType: ToolType
    let pricePerDay: String
    let description: String
    let availabilityDate: Date
    let condition: Condition
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(toolName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(toolType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("$\(pricePerDay)/day")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            
            Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Label("Available from", systemImage: "calendar")
                            Spacer()
                            Text(availabilityDate.formatted(date: .long, time: .omitted))
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Label("Condition", systemImage: "star.fill")
                            Spacer()
                            Text(condition.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(condition.color.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }

            struct SectionTitle: View {
                let title: String
                let icon: String
                
                var body: some View {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .foregroundColor(.blue)
                            .font(.system(size: 24, weight: .semibold))
                        
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }

            enum ToolType: String, CaseIterable {
                case powerTools = "Power Tools"
                case gardenTools = "Garden Tools"
                case handTools = "Hand Tools"
                case automotive = "Automotive"
                case electronics = "Electronics"
                
                var icon: String {
                    switch self {
                    case .powerTools: return "bolt.fill"
                    case .gardenTools: return "leaf.fill"
                    case .handTools: return "hammer.fill"
                    case .automotive: return "car.fill"
                    case .electronics: return "desktopcomputer"
                    }
                }
            }

            enum Condition: String, CaseIterable {
                case excellent = "Excellent"
                case good = "Good"
                case fair = "Fair"
                
                var color: Color {
                    switch self {
                    case .excellent: return .green
                    case .good: return .blue
                    case .fair: return .orange
                    }
                }
            }

            struct ImagePicker: UIViewControllerRepresentable {
                @Binding var selectedImages: [UIImage]
                @Environment(\.presentationMode) private var presentationMode
                
                func makeUIViewController(context: Context) -> UIImagePickerController {
                    let picker = UIImagePickerController()
                    picker.delegate = context.coordinator
                    picker.allowsEditing = false
                    picker.sourceType = .photoLibrary
                    return picker
                }
                
                func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
                
                func makeCoordinator() -> Coordinator {
                    Coordinator(self)
                }
                
                class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
                    let parent: ImagePicker
                    
                    init(_ parent: ImagePicker) {
                        self.parent = parent
                    }
                    
                    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                        if let image = info[.originalImage] as? UIImage {
                            parent.selectedImages.append(image)
                        }
                        parent.presentationMode.wrappedValue.dismiss()
                    }
                }
            }

            struct AddItemView_Previews: PreviewProvider {
                static var previews: some View {
                    AddItemView()
                }
            }
