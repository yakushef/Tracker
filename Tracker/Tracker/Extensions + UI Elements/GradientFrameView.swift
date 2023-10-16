//
//  GradientFrameView.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 18.09.2023.
//

import UIKit

final class GradientFrameView: UIView {
    
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
