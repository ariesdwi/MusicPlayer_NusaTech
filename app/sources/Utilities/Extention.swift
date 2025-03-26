//
//  Extention.swift
//  MusicPlayer_Nusatech
//
//  Created by Aries Prasetyo on 26/03/25.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        self.image = placeholder
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let cachedImage = ImageCache.shared.get(url) {
                DispatchQueue.main.async {
                    self?.image = cachedImage
                }
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else { return }

                ImageCache.shared.save(image, for: url)
                
                DispatchQueue.main.async {
                    self?.image = image
                }
            }.resume()
        }
    }
}

// MARK: - Simple Image Caching
final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    func get(_ url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }

    func save(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
