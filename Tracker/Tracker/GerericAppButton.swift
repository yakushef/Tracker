//
//  GerericAppButton.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 23.08.2023.
//

import UIKit

final class GenericAppButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .appColors.black
        self.tintColor = .appColors.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
    
    func switchActiveState() {
        if isEnabled {
            isEnabled = false
            backgroundColor = .appColors.gray
        } else {
            isEnabled = true
            backgroundColor = .appColors.black
        }
    }
    
    func switchActiveState(isActive: Bool) {
        if isActive {
            isEnabled = true
            backgroundColor = .appColors.black
        } else {
            isEnabled = false
            backgroundColor = .appColors.gray
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

