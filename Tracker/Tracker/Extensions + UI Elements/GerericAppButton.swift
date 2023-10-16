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
        self.titleLabel?.textColor = .AppColors.white
    }
    
    func switchActiveState() {
        if isEnabled {
            isEnabled = false
            backgroundColor = .AppColors.gray
            titleLabel?.textColor = .white
        } else {
            isEnabled = true
            backgroundColor = .AppColors.black
            titleLabel?.textColor = .AppColors.white
        }
    }
    
    func switchActiveState(isActive: Bool) {
        if isActive {
            isUserInteractionEnabled = true
            backgroundColor = .AppColors.black
            tintColor = .AppColors.white
        } else {
            isUserInteractionEnabled = false
            backgroundColor = .AppColors.gray
            tintColor = .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

