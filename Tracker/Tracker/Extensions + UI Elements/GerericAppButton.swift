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
        
        self.backgroundColor = .AppColors.black
        self.tintColor = .AppColors.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    func switchActiveState() {
        if isEnabled {
            isEnabled = false
            backgroundColor = .AppColors.gray
        } else {
            isEnabled = true
            backgroundColor = .AppColors.black
        }
    }
    
    func switchActiveState(isActive: Bool) {
        if isActive {
            isEnabled = true
            backgroundColor = .AppColors.black
        } else {
            isEnabled = false
            backgroundColor = .AppColors.gray
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

