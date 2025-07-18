//
//  ImageLoader.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/10/25.
//

//
//  ImageLoader.swift
//  BreitlingApp
//
//  High-resolution image handling for luxury watch imagery
//  Optimized caching and loading for product photos, collections, and store images
//

import SwiftUI
import Combine
import Foundation

@MainActor
class ImageLoader: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: ImageError?
    
    // MARK: - Private Properties
    
    private var cancellable: AnyCancellable?
    private let url: URL
    private let cache = ImageCache.shared
    private let session = URLSession.shared
    
    // MARK: - Image Loading Errors
    
    enum ImageError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case decodingError
        case notFound
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid image URL"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .decodingError:
                return "Failed to decode image"
            case .notFound:
                return "Image not found"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(url: URL) {
        self.url = url
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    // MARK: - Image Loading
    
    func load() {
        // Reset state
        error = nil
        
        // Check cache first
        if let cachedImage = cache.getImage(for: url) {
            self.image = cachedImage
            return
        }
        
        // Start loading
        isLoading = true
        
        cancellable = session.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        self?.error = .networkError(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] image in
                    guard let self = self else { return }
                    
                    if let image = image {
                        self.image = image
                        self.cache.setImage(image, for: self.url)
                    } else {
                        self.error = .decodingError
                    }
                }
            )
    }
    
    func cancel() {
        cancellable?.cancel()
        isLoading = false
    }
}

// MARK: - Image Cache

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        // Set up memory cache
        cache.countLimit = 100 // Store up to 100 images in memory
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
        
        // Set up disk cache directory
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDir.appendingPathComponent("BreitlingImageCache")
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Set up cache cleanup
        setupCacheCleanup()
    }
    
    // MARK: - Cache Operations
    
    func getImage(for url: URL) -> UIImage? {
        // Check memory cache first
        if let image = cache.object(forKey: url as NSURL) {
            return image
        }
        
        // Check disk cache
        if let image = getImageFromDisk(for: url) {
            // Store in memory cache for faster access
            cache.setObject(image, forKey: url as NSURL)
            return image
        }
        
        return nil
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        // Store in memory cache
        cache.setObject(image, forKey: url as NSURL)
        
        // Store in disk cache
        saveImageToDisk(image, for: url)
    }
    
    func removeImage(for url: URL) {
        // Remove from memory cache
        cache.removeObject(forKey: url as NSURL)
        
        // Remove from disk cache
        removeImageFromDisk(for: url)
    }
    
    func clearCache() {
        // Clear memory cache
        cache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Disk Cache Operations
    
    private func getImageFromDisk(for url: URL) -> UIImage? {
        let fileName = url.absoluteString.sha256
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    private func saveImageToDisk(_ image: UIImage, for url: URL) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let fileName = url.absoluteString.sha256
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try? data.write(to: fileURL)
    }
    
    private func removeImageFromDisk(for url: URL) {
        let fileName = url.absoluteString.sha256
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Cache Management
    
    private func setupCacheCleanup() {
        // Clean up old cache files on app launch
        cleanupOldFiles()
        
        // Set up periodic cleanup
        Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
            Task { @MainActor in
                self.cleanupOldFiles()
            }
        }
    }
    
    private func cleanupOldFiles() {
        let maxAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
        let cutoffDate = Date().addingTimeInterval(-maxAge)
        
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey]) else {
            return
        }
        
        for file in files {
            guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
                  let modificationDate = attributes[.modificationDate] as? Date else {
                continue
            }
            
            if modificationDate < cutoffDate {
                try? fileManager.removeItem(at: file)
            }
        }
    }
    
    // MARK: - Cache Info
    
    func getCacheSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return files.compactMap { file in
            try? fileManager.attributesOfItem(atPath: file.path)[.size] as? Int64
        }.reduce(0, +)
    }
    
    func getCacheInfo() -> CacheInfo {
        let diskSize = getCacheSize()
        let memoryCount = cache.totalCostLimit
        
        return CacheInfo(
            diskSize: diskSize,
            memoryLimit: memoryCount,
            formattedDiskSize: ByteCountFormatter.string(fromByteCount: diskSize, countStyle: .file)
        )
    }
}

// MARK: - SwiftUI Integration

struct AsyncImageView: View {
    @StateObject private var loader: ImageLoader
    
    let placeholder: () -> AnyView
    let content: (UIImage) -> AnyView
    
    init(
        url: URL,
        @ViewBuilder placeholder: @escaping () -> some View = {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: BreitlingColors.accent))
        },
        @ViewBuilder content: @escaping (UIImage) -> some View = { image in
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    ) {
        self._loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = { AnyView(placeholder()) }
        self.content = { AnyView(content($0)) }
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(image)
            } else if loader.isLoading {
                placeholder()
            } else if loader.error != nil {
                Image(systemName: "photo")
                    .foregroundColor(BreitlingColors.mediumGray)
                    .font(.system(size: 24))
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load()
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// MARK: - Luxury Product Image View

struct LuxuryProductImageView: View {
    let imageURL: String
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    
    init(imageURL: String, aspectRatio: CGFloat = 1.0, cornerRadius: CGFloat = 8.0) {
        self.imageURL = imageURL
        self.aspectRatio = aspectRatio
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let uiImage = loadImageFromAssets() {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                // Elegant placeholder for missing images
                WatchImagePlaceholder(
                    collectionName: extractCollectionName(),
                    aspectRatio: aspectRatio,
                    cornerRadius: cornerRadius
                )
            }
        }
    }
    
    private func loadImageFromAssets() -> UIImage? {
        // Try multiple path strategies
        let paths = [
            imageURL,                                          // Direct name
            "product_images/\(imageURL)",                     // With product_images folder
            "product_images/navitimer/\(imageURL)",           // Navitimer folder
            "product_images/superocean/\(imageURL)",          // Superocean folder
            "product_images/chronomat/\(imageURL)",           // Chronomat folder
            "product_images/premier/\(imageURL)",             // Premier folder
            "product_images/avenger/\(imageURL)",             // Avenger folder
            "images/\(imageURL)",                             // Alternative images folder
            "\(imageURL).jpg",                                // With extension
            "\(imageURL).png"                                 // With PNG extension
        ]
        
        for path in paths {
            if let image = UIImage(named: path) {
                print("✅ Found image at: \(path)")
                return image
            }
        }
        
        print("❌ Image not found: \(imageURL)")
        return nil
    }
    
    private func extractCollectionName() -> String {
        // Extract collection name from image URL for better placeholder
        if imageURL.contains("navitimer") { return "Navitimer" }
        if imageURL.contains("superocean") { return "Superocean" }
        if imageURL.contains("chronomat") { return "Chronomat" }
        if imageURL.contains("premier") { return "Premier" }
        if imageURL.contains("avenger") { return "Avenger" }
        return "Breitling"
    }
}

struct WatchImagePlaceholder: View {
    let collectionName: String
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        BreitlingColors.navyBlue.opacity(0.8),
                        BreitlingColors.navyBlue.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .aspectRatio(aspectRatio, contentMode: .fit)
            .overlay {
                VStack(spacing: 12) {
                    // Watch icon
                    Image(systemName: "applewatch")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Collection name
                    Text(collectionName)
                        .font(BreitlingFonts.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    // Subtle "Coming Soon" text
                    Text("Image Loading...")
                        .font(BreitlingFonts.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding()
            }
            .overlay {
                // Subtle border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(BreitlingColors.luxuryGold.opacity(0.3), lineWidth: 1)
            }
    }
}
// MARK: - Hero Image View (for collections and banners)

struct HeroImageView: View {
    let imageURL: String
    let height: CGFloat
    let overlay: AnyView?
    
    init(
        imageURL: String,
        height: CGFloat = 200,
        @ViewBuilder overlay: @escaping () -> some View = { EmptyView() }
    ) {
        self.imageURL = imageURL
        self.height = height
        self.overlay = AnyView(overlay())
    }
    
    var body: some View {
        if let url = URL(string: imageURL) {
            AsyncImageView(url: url) {
                Rectangle()
                    .fill(BreitlingColors.cardBackground)
                    .frame(height: height)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: BreitlingColors.accent))
                    }
            } content: { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: height)
                    .clipped()
            }
            .overlay {
                overlay
            }
        } else {
            Rectangle()
                .fill(BreitlingColors.cardBackground)
                .frame(height: height)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundColor(BreitlingColors.mediumGray)
                        .font(.system(size: 32))
                }
        }
    }
}

// MARK: - Supporting Types

struct CacheInfo {
    let diskSize: Int64
    let memoryLimit: Int
    let formattedDiskSize: String
}

// MARK: - String Extension for SHA256

extension String {
    var sha256: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// Import for SHA256
import CommonCrypto
