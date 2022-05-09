//
//  UserInfoVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-20.
//

import UIKit

protocol UserInfoVCDelegate : AnyObject {
    func didRequestFollowers(for username: String)
}

class UserInfoVC: UIViewController {
    
    let headerView          = UIView()
    let itemViewOne         = UIView()
    let itemViewTwo         = UIView()
    let dateLabel           = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    var username: String!
    weak var delegate: UserInfoVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        getUserInfo()
        layoutUI()
    }
    
    
    func configureViewController(){
        view.backgroundColor                = .systemBackground
        let doneButton                      = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        let addButton                                           = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        navigationItem.rightBarButtonItem   = doneButton
        navigationItem.leftBarButtonItem    = addButton
    }
    
    
    func getUserInfo() {
        Task {
            do {
                let user = try await NetworkManager.shared.getUser(for: username)
                configureUI(with: user)
            } catch {
                guard let GFError = error as? GFError else {
                    presentDefaultErrorAlert()
                    return
                }
                presentGFAlert(title: "Something Went Wrong ", message: GFError.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    
    func configureUI(with user: User) {
        let repoItemVC = GFRepoItemVC(user: user)
        repoItemVC.delegate = self
        
        let followerItemVC = GFFollowerItemVC(user: user)
        followerItemVC.delegate = self
        
        
        self.add(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followerItemVC, to: self.itemViewTwo)
        self.dateLabel.text = "On Github since \(user.createdAt.formatted(.dateTime.month().year()))"
    }
    
    
    func layoutUI() {
        
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        
        for itemView in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            // adds leading and trailing constraints so that views dont bleed to left/right edge of screen
            // using a loop to simplify the code, otherwise the below constraint array would contain very repetitive code for all itemViews
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            itemViewOne.heightAnchor.constraint(equalToConstant: 140),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: 20),
            itemViewTwo.heightAnchor.constraint(equalToConstant: 140),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    
    func addToFavouritesListAndPersistenceManager(with user: User) {
        let favourite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favourite: favourite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            
            guard let error = error else {
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Success!", message: "You have succesfully favourited this user!", buttonTitle: "Hooray!")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Something Went Wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }
    
    
    @objc func addButtonTapped() {
        Task {
            do {
                let user = try await NetworkManager.shared.getUser(for: username)
                addToFavouritesListAndPersistenceManager(with: user)
            } catch {
                guard let GFError = error as? GFError else {
                    presentDefaultErrorAlert()
                    return
                }
                presentGFAlert(title: "Something Went Wrong", message: GFError.rawValue, buttonTitle: "Ok")
            }
            
        }
    }
    
    
    @objc func dismissVC(){
        dismiss(animated: true)
    }
    
}

extension UserInfoVC : GFRepoItemVCDelegate {
    func didTapGithubProfile(for user: User) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlert(title: "Invalid URL", message: "The URL attached to this user is invalid.", buttonTitle: "Ok")
            return
        }
        presentSafariVC(with: url)
    }
}

extension UserInfoVC : GFFollowerItemVCDelegate {
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGFAlert(title: "No Followers", message: "This user has no followers 😪", buttonTitle: "Ok")
            return
        }
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }
}
