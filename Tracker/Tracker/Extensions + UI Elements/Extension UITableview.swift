//
//  Extension UITableview.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 18.09.2023.
//

import UIKit

extension UITableView {
    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        
        self.separatorColor = .AppColors.gray
    }
}
