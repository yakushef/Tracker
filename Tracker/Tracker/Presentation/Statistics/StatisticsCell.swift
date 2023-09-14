//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 13.09.2023.
//

import UIKit

class GradientView: UIView {
    
    lazy var gradientLayer: CAGradientLayer = self.layer as! CAGradientLayer
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.colors = [
            UIColor(red: 0.99, green: 0.3, blue: 0.29, alpha: 1).cgColor,
            UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1).cgColor,
            UIColor(red: 0, green: 0.48, blue: 0.98, alpha: 1).cgColor
        ]
        
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.lineWidth = 1
        gradientLayer.mask = maskLayer
    }
}

final class StatisticsCell: UITableViewCell {
    
    lazy var borderView = {
        let view = GradientView()
        view.backgroundColor = .AppColors.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let labelStack = UIStackView()
    let daysLabel = UILabel()
    let descriptionLabel = UILabel()

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
