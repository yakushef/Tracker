//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    var placeholder = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .AppColors.white

        let statTitle = NSLocalizedString("statisticsPage.title",
                                          comment: "Заголовок экрана статистики")
        navigationItem.title = statTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        placeholder = EmptyTablePlaceholder(type: .statistics, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
    }

}
