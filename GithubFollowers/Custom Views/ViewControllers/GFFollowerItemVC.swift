//
//  GFFollowerItemVC.swift
//  GithubFollowers
//  2/2 Subclass VC's for GFItemInfoViewVC, containing custom protocol and designs
//  Created by Adam S on 2022-04-24.
//

import UIKit

protocol GFFollowerItemVCDelegate : AnyObject {
    func didTapGetFollowers(for user: User)
}

class GFFollowerItemVC: GFItemInfoVC {
    
    var delegate: GFFollowerItemVCDelegate!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    
    private func configureItems(){
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(color: .systemGreen, title: "Get Followers", systemImageName: "person.3")
    }
    
    
    override func actionButtonTapped() {
        delegate.didTapGetFollowers(for: user) 
    }
    
}
