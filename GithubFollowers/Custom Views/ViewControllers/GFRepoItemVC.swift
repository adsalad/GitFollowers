//
//  GFRepoItemVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-24.
//

import UIKit

protocol GFRepoItemVCDelegate : AnyObject {
    func didTapGithubProfile(for user: User)
}

class GFRepoItemVC: GFItemInfoVC {
    
    var delegate: GFRepoItemVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    
    private func configureItems(){
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
        actionButton.set(color: .systemPurple, title: "GitHub Profile", systemImageName: "person")
    }
    
    
    override func actionButtonTapped() {
        delegate.didTapGithubProfile(for: user)
    }
    
}
