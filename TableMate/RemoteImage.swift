import SwiftUI

class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]

    func get(_ key: String) -> UIImage? {
        return cache[key]
    }

    func set(_ key: String, image: UIImage) {
        cache[key] = image
    }
}

struct RemoteImage: View {
    let url: String
    let id: String
    @State private var image: UIImage?

    init(url: String, id: UUID = UUID()) {
        self.url = url
        self.id = id.uuidString
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loadImage)
    }

    private func loadImage() {
        let cacheKey = url + id
        if let cachedImage = ImageCache.shared.get(cacheKey) {
            self.image = cachedImage
            return
        }

        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                    ImageCache.shared.set(cacheKey, image: uiImage)
                }
            }
        }.resume()
    }
}
