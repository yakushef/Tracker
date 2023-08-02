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

        
        let statVC = UINavigationController(rootViewController: StatisticsViewController())
        statVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), selectedImage: nil)
        
        
        viewControllers = [trackersVC, statVC]
        
        let dividerView = UIView(frame: CGRect(x: tabBar.frame.minX, y: 0, width: tabBar.frame.width, height: 0.5))
        dividerView.backgroundColor = UIColor.appColors.gray
        tabBar.addSubview(dividerView)

        tabBar.tintColor = .appColors.blue
    }
}

#Preview {
    let tab = MainListTabBar()
    tab.awakeFromNib()
    
    return tab
}
