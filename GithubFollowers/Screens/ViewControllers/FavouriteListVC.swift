//
//  FavouriteListVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-03-30.
//

import UIKit

class FavouriteListVC: UIViewController {
    
    let tableView = UITableView()
    var favourites : [Follower] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavourites()
    }
    
    func configureViewController() {
        view.backgroundColor    = .systemBackground
        title                   = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame         = view.bounds
        tableView.rowHeight     = 80
        tableView.delegate      = self
        tableView.dataSource    = self
        
        tableView.register(GFFavouriteCell.self, forCellReuseIdentifier: GFFavouriteCell.reuseID)
    }
    
    
    func getFavourites() {
        PersistenceManager.retrieveFavourites { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let favourites):
                self.updateUIWithFavourites(with: favourites)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "Ok")
                }
            }
        }
    }
    
    
    func updateUIWithFavourites(with favourites: ([Follower])) {
        if favourites.isEmpty
        {
            DispatchQueue.main.async {
                self.showEmptyScreenView(with: "No Favourites?\nSelect a user to add one! 🧑‍💻", in: self.view)
            }
        }
        else {
            self.favourites = favourites
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
}

extension FavouriteListVC: UITableViewDelegate, UITableViewDataSource {
    
    // return count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favourites.count
    }
    
    // present cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GFFavouriteCell.reuseID) as! GFFavouriteCell
        let favourite = favourites[indexPath.row]
        cell.set(favorite: favourite)
        return cell
    }
    
    // handle row tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite    = favourites[indexPath.row]
        let followerListVC      = FollowersListVC(username: favorite.login)
        
        navigationController?.pushViewController(followerListVC, animated: true)
    }
    
    // handle slide to delete button for UI and Persistence Manager
    // if there is no error, present empty screen view
    // if there is an error, present an alert with that error
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let favourite = favourites[indexPath.row]
        favourites.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        
        PersistenceManager.updateWith(favourite: favourite, actionType: .remove) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.updateUIWithFavourites(with: self.favourites) // update UI, otherwise EmptyScreen view wont appear
                return
            }
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
}
