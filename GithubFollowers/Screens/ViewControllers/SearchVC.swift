//
//  SearchVC.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-03-30.
//
//
import UIKit

class SearchVC: UIViewController {
    
    let logoImageView       = UIImageView()
    let usernameTextField   = GFTextField()
    let callToActionButton  = GFButton(color: .systemGreen, title: "Get Followers", systemImageName: "person.3")
    
    var isUserNameEntered: Bool {
        return !usernameTextField.text!.isEmpty
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubviews(logoImageView, usernameTextField, callToActionButton)
        configureLogoImageView()
        configureTextField()
        configureCalltoActionButton()
        dismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.text = ""
        navigationController?.isNavigationBarHidden = true
    }
    
    
    func dismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing)) // tap to dismiss
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func pushFollowersListVC () {
        guard isUserNameEntered else {
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Empty Username!", message: "Please Enter a Username 🙂", buttonTitle: "Ok")
            }
            return
        }
        
        let followersListVC = FollowersListVC(username: usernameTextField.text!)
        navigationController?.pushViewController(followersListVC, animated: true)
    }
    
    
    func configureLogoImageView() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = Images.ghLogo
        
        let topConstraintConstant : CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 20 : 80
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstraintConstant),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    
    func configureTextField() {
        usernameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    func configureCalltoActionButton() {
        callToActionButton.addTarget(self, action: #selector(pushFollowersListVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            callToActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            callToActionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            callToActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            callToActionButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
}


extension SearchVC: UITextFieldDelegate {
    
    // navigate to FollowerListVC if 'Enter' is tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowersListVC()
        return true
    }
}
