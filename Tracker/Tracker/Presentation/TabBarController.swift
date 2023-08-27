//
//  TabBarController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class MainListTabBar: UITabBarController {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        
        let trackersVC = UINavigationController(rootViewController: TrackerListViewController())
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackers"), selectedImage: nil)
        trackersVC.navigationController?.navigationBar.prefersLargeTitles = true
        trackersVC.navigationItem.largeTitleDisplayMode = .never

        
        let statVC = UINavigationController(rootViewController: StatisticsViewController())
        statVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "stats"), selectedImage: nil)
        
        viewControllers = [trackersVC, statVC]

        tabBar.tintColor = .AppColors.blue
        

        let dividerView = UIView(frame: CGRect(x: tabBar.frame.minX, y: 0, width: tabBar.frame.width, height: 0.5))
        dividerView.backgroundColor = UIColor.AppColors.gray
        tabBar.addSubview(dividerView)
    }
}

