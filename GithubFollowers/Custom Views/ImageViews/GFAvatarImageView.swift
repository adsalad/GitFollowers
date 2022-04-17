//
//  GFAvatarImageView.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-10.
//

import UIKit

class GFAvatarImageView: UIImageView {
    
    let cache               = NetworkManager.shared.cache
    let placeholderImage    = UIImage(named: "avatar-placeholder")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        layer.cornerRadius  = 10
        clipsToBounds       = true
        image               = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    // didnt see the point of putting this in NetworkManager since we don't need error handling for image retreival
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) {
            self.image = image
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if error != nil { return }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { return }
            guard let data = data else { return }
            
            guard let image = UIImage(data: data) else { return }
            self?.cache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }
        task.resume()
    }
    
}
