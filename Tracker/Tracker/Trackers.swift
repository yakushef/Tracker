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
    let trackerType: type
    let timetable: [Weekday]
    
    enum type {
        case singleEvent
        case habit
    }
    
    init(eventTitle: String, emoji: String, color: UIColor) {
        self.title = eventTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .singleEvent
        self.timetable = [.monday,
                          .tuesday,
                          .wednesday,
                          .thursday,
                          .friday,
                          .saturday,
                          .sunday]
    }
    
    init(habitTitle: String, emoji: String, color: UIColor, timetable: [Weekday]) {
        self.title = habitTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .habit
        self.timetable = timetable
    }
    
    static let test: [Tracker] = [Tracker(habitTitle: "Mic Check 1",
                                          emoji: emojiList.randomElement() ?? "🛼",
                                          color: .colorSections.section11,
                                          timetable: [.monday, .wednesday, .friday]),
                                  Tracker(eventTitle: "Check 2-1-2",
                                          emoji:  emojiList.randomElement() ?? "🎮",
                                          color: .colorSections.section13)]
}
