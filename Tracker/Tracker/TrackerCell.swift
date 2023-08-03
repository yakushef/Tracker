//
//  TrackerCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 03.08.2023.
//

import UIKit

final class TrackerTypeHeader: UICollectionReusableView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 12),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        label.text = "Check Yo Head"
        label.font = .boldSystemFont(ofSize: 19)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class TrackerCell: UICollectionViewCell {
    var cardView = UIView()
    var emojiLabel = UILabel()
    var pinImage = UIImageView()
    var titleLabel = UILabel()
    
    var managementView = UIView()
    var incrementButton = UIButton()
    var daysLabel = UILabel()
    
    var cellTracker: Tracker?
    
    func configureCell(with tracker: Tracker) {
        //MARK: - Card View
        
        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor)
        ])
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = tracker.color
        
        //MARK: - Pin Image
        
        pinImage.image = UIImage(named: "Pin")
        cardView.addSubview(pinImage)
        pinImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pinImage.heightAnchor.constraint(equalToConstant: 24),
            pinImage.widthAnchor.constraint(equalToConstant: 24),
            pinImage.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4)
        ])
        
        //MARK: - Emoji
        
        cardView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.backgroundColor = .appColors.backgroundDay
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.text = tracker.emoji
        
        //MARK: - Title
        
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .appColors.whiteDay
        titleLabel.text = tracker.title
        
        //MARK: - Management
        
        addSubview(managementView)
        managementView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            managementView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            managementView.bottomAnchor.constraint(equalTo: bottomAnchor),
            managementView.leadingAnchor.constraint(equalTo: leadingAnchor),
            managementView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        //MARK: - Increment Button
        
        incrementButton = UIButton.systemButton(with: UIImage(systemName: "plus") ?? UIImage(), target: self, action: nil)
        managementView.addSubview(incrementButton)
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            incrementButton.heightAnchor.constraint(equalToConstant: 34),
            incrementButton.widthAnchor.constraint(equalToConstant: 34),
            incrementButton.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            incrementButton.trailingAnchor.constraint(equalTo: managementView.trailingAnchor, constant: -12)
        ])
        incrementButton.backgroundColor = tracker.color
        incrementButton.tintColor = .appColors.whiteDay
        incrementButton.clipsToBounds = true
        incrementButton.layer.cornerRadius = 17
        
        //MARK: - Day Label
        
        daysLabel = UILabel()
        managementView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(equalTo: managementView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -8),
            daysLabel.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            daysLabel.bottomAnchor.constraint(equalTo: incrementButton.bottomAnchor)
        ])
        daysLabel.font = .systemFont(ofSize: 12)
        daysLabel.text = "День в день"
    }
}

#Preview {
    let tab = MainListTabBar()
    tab.awakeFromNib()
    
    return tab
}
