//
//  UIImageView+extension.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/16.
//

import UIKit

final class ImageCacheManager {
    static let shared = NSCache<NSString, UIImage>()

    private init() { }
}

extension UIImageView {
    func setImage(with url: String) {
        let cacheKey = NSString(string: url)
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            DispatchQueue.main.async { [weak self] in
                self?.image = cachedImage
            }
            return
        }

        DispatchQueue.global().async {
            guard let imageURL = URL(string: url),
                  let imageData = try? Data(contentsOf: imageURL),
                  let image = UIImage(data: imageData) else {
                DispatchQueue.main.async { [weak self] in
                    self?.image = UIImage(named: "noimg")
                }
                return
            }

            ImageCacheManager.shared.setObject(image, forKey: cacheKey)
            DispatchQueue.main.async { [weak self] in
                self?.image = image
            }
        }
    }
}
