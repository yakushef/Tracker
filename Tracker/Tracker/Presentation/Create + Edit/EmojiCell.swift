//
//  EmojiCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 27.08.2023.
//

import UIKit

class EmojiCell: UICollectionViewCell {
    private var emojiCellLabel = UILabel()
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .AppColors.background : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        emojiCellLabel.font = .boldSystemFont(ofSize: 32)
        addSubview(emojiCellLabel)
        emojiCellLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiCellLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiCellLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        layer.cornerRadius = 16
    }
    
    func setEmoji(_ emoji: String) {
        guard emoji.count == 1 else {
            emojiCellLabel.text = "🌚"
            return
        }
        emojiCellLabel.text = emoji
    }
}
