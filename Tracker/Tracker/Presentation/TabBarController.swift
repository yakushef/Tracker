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
        let trackersTitle = NSLocalizedString("trackerPage.title",
                                              comment: "Заголовок страницы трекеров")
        trackersVC.tabBarItem = UITabBarItem(title: trackersTitle,
                                             image: UIImage(named: "trackers"),
                                             selectedImage: nil)
        trackersVC.navigationController?.navigationBar.prefersLargeTitles = true
        trackersVC.navigationItem.largeTitleDisplayMode = .never

        
        let statVC = UINavigationController(rootViewController: StatisticsViewController())
        let ststTitle = NSLocalizedString("statisticsPage.title",
                                          comment: "Заголовок страницы статистики")
        statVC.tabBarItem = UITabBarItem(title: ststTitle,
                                         image: UIImage(named: "stats"),
                                         selectedImage: nil)
        
        viewControllers = [trackersVC, statVC]

        tabBar.tintColor = .AppColors.blue
        
        let dividerView = UIView(frame: CGRect(x: tabBar.frame.minX, y: 0, width: tabBar.frame.width, height: 0.5))
        dividerView.backgroundColor = UIColor.AppColors.divider
        tabBar.addSubview(dividerView)
    }
}

