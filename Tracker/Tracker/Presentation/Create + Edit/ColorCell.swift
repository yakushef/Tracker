//
//  ColorCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 27.08.2023.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet {
            setImage()
        }
    }
    
    private let shapeView = UIImageView()
    
    override func awakeFromNib() {
        addSubview(shapeView)
        shapeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shapeView.topAnchor.constraint(equalTo: topAnchor),
            shapeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shapeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shapeView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        shapeView.contentMode = .scaleAspectFit
        setImage()
    }
    
    private func setImage() {
        let image = UIImage(named: isSelected ? "ColorActive" : "ColorInactive")?.withRenderingMode(.alwaysTemplate)
        shapeView.image = image
    }
    
    func setColor(_ color: UIColor) {
        shapeView.tintColor = color
    }
}
