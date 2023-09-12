//
//  FilterViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 06.08.2023.
//

import UIKit

final class FilterViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .AppColors.white
        navigationItem.title = NSLocalizedString("filters",
                                                 comment: "Заголовок страницы фильтров")
    }
}
