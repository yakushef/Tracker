//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

class StatisticsViewController: UIViewController {
    
    var placeholder = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        placeholder = EmptyTablePlaceholder(type: .statistics, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
    }

}
