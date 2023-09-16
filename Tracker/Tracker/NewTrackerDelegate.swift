//
//  NewTrackerDelegate.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 17.08.2023.
//

import UIKit

protocol NewTrackerDelegateProtocol: AnyObject {
    var newTrackerTitle: String {get}
    var newTrackerType: Tracker.type {get}
    var newTrackerName: String {get}
    var newTrackerSchedule: Set<Weekday> {get}
    var newTrackEmoji: String? {get}
    var newTrackColor: UIColor? {get}
    var newTrackerCategoryName: String {get}
    
    func setTrackerTitle(to title: String)
    func setTrackerType(to type: Tracker.type)
    func setTrackerSchedule(to schedule: Set<Weekday>)
    func setNewTrackerCategoryName(to category: String)
    func setRandomEmoji()
    func setTrackerEmoji(to emoji: String)
    func setRandomColor()
    func setTrackerColor(to color: UIColor)
    
    func wipeAllTrackerInfo()
    func createNewTracker()
}

final class NewTrackerDelegate: NewTrackerDelegateProtocol {

    static let shared = NewTrackerDelegate()
    let storageService = StorageService.shared
    
    weak var trackerListVC: TrackerListViewController?
    weak var newTrackerVC: NewTrackerViewController?
    weak var timetableVC: TimetableViewController?
    
    var newTrackerTitle: String = ""
    var newTrackerType: Tracker.type = .habit
    var newTrackerName: String = ""
    var newTrackerSchedule: Set<Weekday> = [] {
        didSet {
            newTrackerVC?.activeDays = newTrackerSchedule
        }
    }
    var newTrackEmoji: String? = nil {
        didSet {
            newTrackerVC?.newTrackerEmoji = newTrackEmoji
        }
    }
    var newTrackColor: UIColor? = nil {
        didSet {
            newTrackerVC?.newTrackerColor = newTrackColor
        }
    }
    private(set) var newTrackerCategoryName: String = ""
    
    func setTrackerTitle(to title: String) {
        newTrackerTitle = title
    }
    
    func setTrackerType(to type: Tracker.type) {
        newTrackerType = type
    }
    
    func setTrackerSchedule(to schedule: Set<Weekday>) {
        newTrackerSchedule = schedule
    }
    
    func setNewTrackerCategoryName(to category: String) {
        newTrackerCategoryName = category
        newTrackerVC?.category = category
    }
    
    func setTrackerEmoji(to emoji: String) {
        if emoji.count == 1 {
            newTrackEmoji = emoji
        }
    }
    
    func setTrackerColor(to color: UIColor) {
        newTrackColor = color
    }
    
    func setRandomEmoji() {
        newTrackEmoji = emojiList.randomElement() ?? "🧩"
    }
    
    func setRandomColor() {
        newTrackColor = sectionColors.randomElement() ?? .AppColors.gray
    }
    
    func wipeAllTrackerInfo() {
        newTrackerTitle = ""
        newTrackerType = .habit
        newTrackerName = ""
        newTrackerSchedule = []
        newTrackEmoji = nil
        newTrackColor = nil
    }
    
    func createNewTracker() {
        var tracker: Tracker
        switch newTrackerType {
        case .habit:
            var days: [Weekday] = []
            days.append(contentsOf: newTrackerSchedule)
            tracker = Tracker(habitTitle: newTrackerTitle,
                              emoji: newTrackEmoji  ?? "🧩",
                              color: newTrackColor ?? .AppColors.gray,
                              timetable: days)
        case .singleEvent:
            tracker = Tracker(eventTitle: newTrackerTitle,
                              emoji: newTrackEmoji  ?? "🧩",
                              color: newTrackColor ?? .AppColors.gray)
        }
        
        storageService.addTracker(tracker, categoryName: newTrackerCategoryName)
        
        trackerListVC?.newTrackerAdded()
    }
}
