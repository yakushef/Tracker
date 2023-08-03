//
//  Trackers.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 02.08.2023.
//

import UIKit

struct Tracker {
    let title: String
    let emoji: String
    let color: UIColor
    
    static let test: [Tracker] = [Tracker(title: "Test 1", emoji: "🛼", color: .colorSections.section11),
                                  Tracker(title: "Test 2", emoji: "🎮", color: .colorSections.section13)]
}
