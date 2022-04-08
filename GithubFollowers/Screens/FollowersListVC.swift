//
//  FollowersListVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-03.
//

import UIKit

class FollowersListVC: UIViewController {
    
    var username  : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
