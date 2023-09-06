//
//  Tracker.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 25.08.2023.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    
    let title: String
    let emoji: String
    let color: UIColor
    let trackerType: type
    let timetable: [Weekday]
    let isPinned: Bool
    
    enum type {
        case singleEvent
        case habit
    }
    
    init(eventTitle: String, emoji: String, color: UIColor, isPinned: Bool = false, id: UUID = UUID()) {
        self.title = eventTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .singleEvent
        self.timetable = weekDays
        self.isPinned = isPinned
        self.id = id
    }
    
    init(habitTitle: String, emoji: String, color: UIColor, timetable: [Weekday], isPinned: Bool = false, id: UUID = UUID()) {
        self.title = habitTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .habit
        self.timetable = timetable
        self.isPinned = isPinned
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
}
