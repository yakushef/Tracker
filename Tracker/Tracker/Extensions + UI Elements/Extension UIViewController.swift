//
//  Extension UIViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 25.08.2023.
//

import UIKit

extension UIViewController {
    func addTapGestureToHideKeyboard(for editedView: UIView) {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(editedView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}
