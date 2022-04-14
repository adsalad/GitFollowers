//
//  GFFollowerCell.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-10.
//

import UIKit

class GFFollowerCell: UICollectionViewCell {
    
    static let reuseID = "GFFollowerCell"
    let usernameLabel = GFTitleLabel(textAlignment: .center, fontSize: 16)
    let avatarImageView = GFAvatarImageView(frame: .zero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(follower: Follower){
        usernameLabel.text = follower.login
        avatarImageView.downloadImage(from: follower.avatarUrl)
    }
    
    
    private func configure() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor), //^
            
            usernameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 12),
            usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            usernameLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
}
