//
//  GFButton.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-03-31.
//

import UIKit

class GFButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    convenience init(color: UIColor, title: String, systemImageName: String){
        self.init(frame: .zero)
        set(color: color, title: title, systemImageName: systemImageName)
    }
    
    
    private func configure() {
        configuration                               = .filled()
        configuration?.cornerStyle                  = .medium
        translatesAutoresizingMaskIntoConstraints   = false
    }
    
    
    final func set(color: UIColor, title: String, systemImageName: String) {
        configuration?.baseBackgroundColor  = color
        configuration?.title                = title
        
        configuration?.image                = UIImage(systemName: systemImageName)
        configuration?.imagePadding         = 6
        configuration?.imagePlacement       = .leading
    }
}



