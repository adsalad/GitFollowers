//
//  FollowersListVC.swift
//  GithubFollowers
//  FollowerListVC presented
//  Created by Adam S on 2022-04-03.
//

import UIKit

class FollowersListVC: UIViewController {
    
    enum Section { case main }
    
    let searchController = UISearchController()
    
    var page: Int = 1
    var username: String!
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var hasMoreFollowers = true
    var isSearching = false
    var isLoadingMoreFollowers = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username   = username
        title           = username
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
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
    
    // using new diffable data source to reload and animate collection view
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GFFollowerCell.reuseID, for: indexPath) as! GFFollowerCell
            cell.set(follower: follower)
            return cell
        })
    }
    
    
    func configureSearchController() {
        searchController.searchBar.delegate         = self
        searchController.searchBar.placeholder      = "Search for a username"
        navigationItem.hidesSearchBarWhenScrolling  = false
        navigationItem.searchController             = searchController
    }
    
    
    // async call to get followers of specific user. This works with protocols below to paginate effectively
    func getFollowers(username: String, page: Int) {
        isLoadingMoreFollowers = true
        
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                updateUIWithFollowers(with: followers)
            } catch {
                guard let GFError = error as? GFError else {
                    presentDefaultErrorAlert()
                    return
                }
                presentGFAlert(title: "Something Went Wrong", message: GFError.rawValue, buttonTitle: "Ok")
            }
            isLoadingMoreFollowers = false
        }
    }
    
    
    // check if there are more followers to load and set flag accordingly, append whatever followers are returned, and update collecion view
    func updateUIWithFollowers(with followers: [Follower]) {
        if followers.count < 30 { self.hasMoreFollowers = false }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user does not have any followers 😪"
            DispatchQueue.main.async {
                self.showEmptyScreenView(with: message, in: self.view)
                return
            }
        }
        self.updateData(in: self.followers)
    }
    
    
    // update collection view
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
    
    // if we reach end up scroll view, load next group of followers using pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
    // handles tapping on specific user, and navigating to UserInfoVC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray     = isSearching ? filteredFollowers : followers
        
        let follower        = activeArray[indexPath.item]
        
        let userInfoVC      = UserInfoVC()
        userInfoVC.delegate = self
        userInfoVC.username = follower.login
        let navController   = UINavigationController(rootViewController: userInfoVC) //present sheet view
        present(navController, animated: true)
    }
}


extension FollowersListVC : UISearchBarDelegate {
    
    // update collection view based on search query
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else { return }
        
        isSearching = true
        
        filteredFollowers = followers.filter({$0.login.lowercased().contains(searchText.lowercased())} )
        updateData(in: filteredFollowers)
    }
}


extension FollowersListVC: UserInfoVCDelegate {
    
    // when Get Followers button is tapped in UserInfoVC, we want to reset our variables, before making the API call
    func didRequestFollowers(for username: String) {
        self.username   = username
        title           = username
        page            = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        hasMoreFollowers = true
        
        if isSearching {
            navigationItem.searchController?.searchBar.text = nil
            navigationItem.searchController?.isActive       = false
            isSearching                                     = false
        }
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        getFollowers(username: username, page: page)
    }
}
