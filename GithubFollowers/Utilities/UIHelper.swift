//
//  UIHelper.swift
//  GithubFollowers
//
//  Created by Adam S on 2022-04-12.
//

import UIKit

enum UIHelper {
    
    // helper function set layout for collection view
    static func configureThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout  {
        let width                       = view.bounds.width
        let padding : CGFloat           = 12
        let minItemSpacing : CGFloat    = 10
        let availableWidth              = width - (padding * 2) - (minItemSpacing * 2)
        let itemWidth                   = availableWidth / 3
        
        let flowLayout                  = UICollectionViewFlowLayout()
        flowLayout.sectionInset         = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize             = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
}
