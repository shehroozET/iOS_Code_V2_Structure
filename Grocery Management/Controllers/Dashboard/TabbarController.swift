//
//  TabbarController.swift
//  Grocery Management
//
//  Created by mac on 03/04/2025.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarAppearance()
    }
    
    private func setupTabBarAppearance() {
        tabBar.unselectedItemTintColor = .black
        let circularIndicator = UIImage.createCircularIndicator(color: UIColor.init(hex: 0xD1EADA), diameter: 44)
        tabBar.selectionIndicatorImage = circularIndicator
    }
}
