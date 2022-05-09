//
//  UIViewController+Ext.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-04.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func presentGFAlert(title: String, message: String, buttonTitle: String) {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle  = .overFullScreen
            alertVC.modalTransitionStyle    = .crossDissolve
            present(alertVC, animated: true)
    }
    
    func presentDefaultErrorAlert() {
            let alertVC = GFAlertVC(title: "Something Went Wrong", message: "Unable to complete task. Please try again!", buttonTitle: "Ok")
            alertVC.modalPresentationStyle  = .overFullScreen
            alertVC.modalTransitionStyle    = .crossDissolve
            present(alertVC, animated: true)
    }
    
    
    func showEmptyScreenView(with message: String, in view: UIView) {
        let emptyStateView = GFEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func presentSafariVC(with url: URL ){
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = .systemPurple
        present(safariVC, animated: true)
    }
}

