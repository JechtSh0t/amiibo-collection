//
//  ImageManager.swift
//
//  Created by JechtSh0t on 12/2/20.
//
import UIKit

///
/// Handles image caching and retrieval.
///
final class ImageManager {
    
    // MARK: - Singleton -
    
    static let shared = ImageManager()
    private init() {
        _ = try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true, attributes: [:])
    }
    
    // MARK: - Properties -
    
    /// The URLs that currently have a download in progress.
    private var activeDownloads = Set<URL>()
    /// Permanent directory for cached images.
    private lazy var imageDirectory: URL = { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("images") }()
}

// MARK: - Save/Load -

extension ImageManager {
    
    ///
    /// Downloads an image from a specified location. If the image has previously been downloaded, it will be taken from cache and returned immediately.
    ///
    /// - parameter source: The location of the image to download.
    /// - returns: An image from cache, if there is one.
    ///
    func loadImage(_ source: URL) -> UIImage? {
        
        // Return image from cache immediately.
        if let cachedImage = loadImageFromCache(source) { return cachedImage }
        
        // There is a previous active download for the image.
        guard !activeDownloads.contains(source) else { return nil }
        
        let downloadTask = URLSession.shared.downloadTask(with: source) { url, response, error in
            
            self.activeDownloads.remove(source)
            
            guard error == nil, let temporaryURL = url, let data = try? Data(contentsOf: temporaryURL), let image = UIImage(data: data) else {
                self.postNotification(for: nil, source: source)
                return
            }
                 
            self.saveImageToCache(from: temporaryURL, source: source)
            self.postNotification(for: image, source: source)
        }
        
        activeDownloads.insert(source)
        downloadTask.resume()
        return nil
    }
    
    ///
    /// Moves an image from temporary download location to the cached images folder.
    ///
    /// - parameter temporaryLocation: The location the image was originally downloaded to.
    /// - parameter source: The server address of the image. The last piece of this is used as the image name.
    ///
    func saveImageToCache(from temporaryLocation: URL, source: URL) {
        
        let components = source.path.components(separatedBy: "/")
        guard components.count == 6 else { return }
       
        try? FileManager.default.copyItem(at: temporaryLocation, to: imageDirectory.appendingPathComponent(components[5]).appendingPathExtension("png"))
    }
    
    ///
    /// Attempts to load an image from the cached images folder.
    ///
    /// - parameter source: The server address of the image. The last piece of this is used as the image name.
    ///
    func loadImageFromCache(_ source: URL) -> UIImage? {
        
        let components = source.path.components(separatedBy: "/")
        guard components.count == 6 else { return nil }
        
        guard let data = FileManager.default.contents(atPath: imageDirectory.appendingPathComponent(components[5]).appendingPathExtension("png").path) else { return nil }
        return UIImage(data: data)
    }
}

// MARK: - Notification -

extension ImageManager {
    
    ///
    /// Posts a notification alerting the application that an image has been loaded.
    ///
    /// - parameter image: The image that was loaded.
    /// - parameter source: the location that the image was loaded from.
    ///
    private func postNotification(for image: UIImage?, source: URL) {
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("imageLoaded"), object: nil, userInfo: ["image": image as Any, "source": source])
        }
    }
}
