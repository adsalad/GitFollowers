//
//  FollowersListVC.swift
//  GithubFollowers
//
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
        
        let addButton                                           = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem                       = addButton
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
        searchController.searchBar.delegate         = self
        searchController.searchBar.placeholder      = "Search for a username"
        navigationItem.hidesSearchBarWhenScrolling  = false
        navigationItem.searchController             = searchController
    }
    
    
    func getFollowers(username: String, page: Int) {
        isLoadingMoreFollowers = true
        
        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                updateUIWithFollowers(with: followers)
            } catch {
                guard let GFError = error as? GFError else {
                    presentDefaultErrorAlert()
                }
                presentGFAlert(title: "Something went wrong", message: GFError.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
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
    
    
    func updateData(in followers : [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    
    @objc func addButtonTapped() {
        
        NetworkManager.shared.getUser(for: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let user):
                self.addToFavouritesListAndPersistenceManager(with: user)
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
                
            }
        }
    }
    
    func addToFavouritesListAndPersistenceManager(with user: User) {
        let favourite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favourite: favourite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have succesfully favourited this user!", buttonTitle: "Hooray!")
                return
            }
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
        }
    }
    
}


extension FollowersListVC : UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.size.height
        
        // load next group of followers
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }
    
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(in: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        
        filteredFollowers = followers.filter({$0.login.lowercased().contains(searchText.lowercased())} )
        updateData(in: filteredFollowers)
    }
}

extension FollowersListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String) {
        self.username   = username
        title           = username
        page            = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        getFollowers(username: username, page: page)
    }
}
