//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 25.08.2023.
//

import Foundation

struct TrackerCategory: Hashable {
    let name: String
    let trackers: [Tracker]
}
