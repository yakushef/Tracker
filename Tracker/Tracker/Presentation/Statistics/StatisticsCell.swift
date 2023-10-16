//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 13.09.2023.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    private lazy var borderView = {
        let view = GradientFrameView()
        view.backgroundColor = .AppColors.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let labelStack = UIStackView()
    private let daysLabel = UILabel()
    private let descriptionLabel = UILabel()

    func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.isHidden = true
        addSubview(borderView)
        borderView.topAnchor.constraint(equalTo: topAnchor, constant: 6).isActive = true
        borderView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        borderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        
        addSubview(labelStack)
        labelStack.axis = .vertical
        labelStack.spacing = 7
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(equalTo: borderView.topAnchor, constant: 12),
            labelStack.bottomAnchor.constraint(equalTo: borderView.bottomAnchor, constant: -12),
            labelStack.leadingAnchor.constraint(equalTo: borderView.leadingAnchor, constant: 12),
            labelStack.trailingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: -12)
        ])
        
        labelStack.addArrangedSubview(daysLabel)
        daysLabel.font = .systemFont(ofSize: 34, weight: .bold)
        labelStack.addArrangedSubview(descriptionLabel)
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
    
    func setDescription(_ description: String) {
        descriptionLabel.text = description
    }
    
    func setDays(_ days: Int) {
        daysLabel.text = "\(days)"
    }
}
