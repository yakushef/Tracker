//
//  EmptyTablePlaceholder.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

final class EmptyTablePlaceholder: UIView {
    enum PlaceholderType {
        case search
        case tracker
        case statistics
        case category
    }
    
    var type: PlaceholderType
    private var placeholderImage = UIImageView()
    private var placeholderLabel = UILabel()
    private var stack = UIStackView()
    
    init(type: PlaceholderType, frame: CGRect) {
        self.type = type
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        setupType()
        setupStack()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not defined")
    }
    
    private func setupType() {
        switch type {
        case .search:
            placeholderImage.image = UIImage(named: "nothingFound") ?? UIImage()
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            placeholderLabel.numberOfLines = 1
            placeholderLabel.text = NSLocalizedString("placeholder.search", comment: "Ничего не найдено")
        case .category:
            placeholderImage.image = UIImage(named: "fallingStar") ?? UIImage()
            placeholderLabel.heightAnchor.constraint(equalToConstant: 36).isActive = true
            placeholderLabel.numberOfLines = 2
            placeholderLabel.text = NSLocalizedString("placeholder.category", comment: "Привычки и события можно\nобъединить по смыслу")
        case .tracker:
            placeholderImage.image = UIImage(named: "fallingStar") ?? UIImage()
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            placeholderLabel.numberOfLines = 1
            placeholderLabel.text = NSLocalizedString("placeholder.trackers", comment: "Что будем отслеживать?")
        case .statistics:
            placeholderImage.image = UIImage(named: "crying") ?? UIImage()
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
            placeholderLabel.numberOfLines = 1
            placeholderLabel.text = NSLocalizedString("placeholder.stats", comment: "Анализировать пока нечего")
        }
    }
    
    private func setupStack() {
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        stack.alignment = .center
        stack.spacing = 8
        stack.axis = .vertical
        stack.addArrangedSubview(placeholderImage)
        stack.addArrangedSubview(placeholderLabel)
        
        placeholderImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
        ])
        placeholderLabel.textAlignment = .center
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 7
        paragraphStyle.alignment = .center
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.attributedText = NSMutableAttributedString(string: placeholderLabel.text ?? "", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
}
