//
//  AppColors.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

let emojiList: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                           "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                           "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]

enum trackerEmojis: String {
    case 🙂, 😻, 🌺, 🐶, 😱, 😇, 😡, 🥶, 🤔, 🙌, 🍔, 🥦, 🏓, 🥇, 🎸, 🏝, 😪
    case heart = "❤️"
}

extension UIColor {
    struct appColors {
        static let blackDay = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        static let blackNight = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        static let whiteDay = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        static let whiteNight = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        
        static let backgroundDay = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        static let backgroundNight = UIColor(red: 0.254, green: 0.254, blue: 0.254, alpha: 0.85)
        
        static let gray = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        static let lightGray = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1)
        
        static let red = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        static let blue = UIColor(red: 0.216, green: 0.447, blue: 0.906, alpha: 1)
    }
    
    struct colorSections {
        static let section1 = UIColor(red: 0.992, green: 0.298, blue: 0.286, alpha: 1)
        static let section2 = UIColor(red: 1, green: 0.533, blue: 0.118, alpha: 1)
        static let section3 = UIColor(red: 0, green: 0.482, blue: 0.98, alpha: 1)
        static let section4 = UIColor(red: 0.431, green: 0.267, blue: 0.996, alpha: 1)
        static let section5 = UIColor(red: 0.2, green: 0.812, blue: 0.412, alpha: 1)
        static let section6 = UIColor(red: 0.902, green: 0.427, blue: 0.831, alpha: 1)
        
        static let section7 = UIColor(red: 0.976, green: 0.831, blue: 0.831, alpha: 1)
        static let section8 = UIColor(red: 0.204, green: 0.655, blue: 0.996, alpha: 1)
        static let section9 = UIColor(red: 0.275, green: 0.902, blue: 0.616, alpha: 1)
        static let section10 = UIColor(red: 0.208, green: 0.204, blue: 0.486, alpha: 1)
        static let section11 = UIColor(red: 1, green: 0.404, blue: 0.302, alpha: 1)
        static let section12 = UIColor(red: 1, green: 0.6, blue: 0.8, alpha: 1)
        
        static let section13 = UIColor(red: 0.965, green: 0.769, blue: 0.545, alpha: 1)
        static let section14 = UIColor(red: 0.475, green: 0.58, blue: 0.961, alpha: 1)
        static let section15 = UIColor(red: 0.514, green: 0.173, blue: 0.945, alpha: 1)
        static let section16 = UIColor(red: 0.678, green: 0.337, blue: 0.855, alpha: 1)
        static let section17 = UIColor(red: 0.553, green: 0.447, blue: 0.902, alpha: 1)
        static let section18 = UIColor(red: 0.184, green: 0.816, blue: 0.345, alpha: 1)
    }
}

let sectionColors: [UIColor] = [.colorSections.section1,
                                .colorSections.section2,
                                .colorSections.section3,
                                .colorSections.section4,
                                .colorSections.section5,
                                .colorSections.section6,
                                .colorSections.section7,
                                .colorSections.section8,
                                .colorSections.section9,
                                .colorSections.section10,
                                .colorSections.section11,
                                .colorSections.section12,
                                .colorSections.section13,
                                .colorSections.section14,
                                .colorSections.section15,
                                .colorSections.section16,
                                .colorSections.section17,
                                .colorSections.section18]
