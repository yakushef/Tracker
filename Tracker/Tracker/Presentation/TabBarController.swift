//
//  TabBarController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

class MainListTabBar: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        
        let trackersVC = UINavigationController(rootViewController: TrackerListViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), selectedImage: nil)
        trackersVC.navigationController?.navigationBar.prefersLargeTitles = true
        trackersVC.navigationItem.largeTitleDisplayMode = .never

        
        let statVC = UINavigationController(rootViewController: StatisticsViewController())
        statVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), selectedImage: nil)
        
        viewControllers = [trackersVC, statVC]

        tabBar.tintColor = .appColors.blue
    }
}

#Preview {
    let tab = MainListTabBar()
    tab.awakeFromNib()
    
    return tab
}
