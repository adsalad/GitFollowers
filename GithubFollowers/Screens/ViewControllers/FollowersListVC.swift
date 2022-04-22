//
//  FollowersListVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-03.
//

import UIKit

class FollowersListVC: UIViewController {
    
    enum Section { case main }
    
    var page: Int = 1
    var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    
    var hasMoreFollowers = true
    var isSearching = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureCollectionVIew()
        configureDataSource()
        configureSearchController()
        getFollowers(username: username, page: page)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func configureViewController() {
        view.backgroundColor                                    = .systemBackground
        navigationController?.isNavigationBarHidden             = false
        navigationController?.navigationBar.prefersLargeTitles  = true
    }
    
    
    func configureCollectionVIew(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.configureThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate         = self
        collectionView.backgroundColor  = .systemBackground
        collectionView.register(GFFollowerCell.self, forCellWithReuseIdentifier: GFFollowerCell.reuseID)
    }
    
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GFFollowerCell.reuseID, for: indexPath) as! GFFollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.delegate         = self
        searchController.searchBar.placeholder      = "Search for a username"
        navigationItem.hidesSearchBarWhenScrolling  = false
        navigationItem.searchController             = searchController
        
    }
    
    func getFollowers(username: String, page: Int) {
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            guard let self = self else { return } //removes need to add optional chaining for self reference
            
            switch result {
            case .success(let followers):
                if followers.count < 30 {self.hasMoreFollowers = false}
                self.followers.append(contentsOf: followers)
                
                if self.followers.isEmpty {
                    let message = "This user does not have any followers 😪"
                    DispatchQueue.main.async {
                        self.showEmptyScreenView(with: message, in: self.view)
                        return
                    }
                }
                self.updateData(in: self.followers)
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad stuff", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    func updateData(in followers : [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}


extension FollowersListVC : UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray     = isSearching ? filteredFollowers : followers
        
        let follower        = activeArray[indexPath.item]
        
        let userInfoVC      = UserInfoVC()
        userInfoVC.username = follower.login
        let navController   = UINavigationController(rootViewController: userInfoVC)
        present(navController, animated: true)
        
    }
}

extension FollowersListVC : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {return}
        
        isSearching = true
        
        filteredFollowers = followers.filter({$0.login.lowercased().contains(searchText.lowercased())} )
        updateData(in: filteredFollowers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(in: followers)
    }
}