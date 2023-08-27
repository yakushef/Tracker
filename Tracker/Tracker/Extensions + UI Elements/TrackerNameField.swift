//
//  TrackerNameField.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 25.08.2023.
//

import UIKit

final class TrackerNameField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 38))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 38))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: self.bounds.width - 38, bottom: 0, right: 16))
    }
}
