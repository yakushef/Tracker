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
    var newTrackEmoji: String {get}
    var newTrackColor: UIColor {get}
    var newTrackerCategoryName: String {get}
    
    func setTrackerTitle(to title: String)
    func setTrackerType(to type: Tracker.type)
    func setTrackerSchedule(to schedule: Set<Weekday>)
    func setNewTrackerCategoryName(to category: String)
    func setTrackerEmoji()
    func setTrackerColor()
    
    func wipeAllTrackerInfo()
    func createNewTracker()
}

final class NewTrackerDelegate: NewTrackerDelegateProtocol {
    
    static let shared = NewTrackerDelegate()
    let storageService = TrackerStorageService.shared
    
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
    var newTrackEmoji: String = "⚠️"
    var newTrackColor: UIColor = .appColors.gray
    var newTrackerCategoryName: String = ""
    
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
    
    func setTrackerEmoji() {
        newTrackEmoji = emojiList.randomElement() ?? "🧩"
    }
    
    func setTrackerColor() {
        newTrackColor = sectionColors.randomElement() ?? .appColors.gray
    }
    
    func wipeAllTrackerInfo() {
        newTrackerTitle = ""
        newTrackerType = .habit
        newTrackerName = ""
        newTrackerSchedule = []
        newTrackEmoji = "⚠️"
        newTrackColor = .appColors.gray
    }
    
    func createNewTracker() {
        var tracker: Tracker
        setTrackerColor()
        setTrackerEmoji()
        switch newTrackerType {
        case .habit:
            var days: [Weekday] = []
            days.append(contentsOf: newTrackerSchedule)
            tracker = Tracker(habitTitle: newTrackerTitle,
                              emoji: newTrackEmoji,
                              color: newTrackColor,
                              timetable: days)
        case .singleEvent:
            tracker = Tracker(eventTitle: newTrackerTitle,
                              emoji: newTrackEmoji,
                              color: newTrackColor)
        }
        
        let sameNameCategories = storageService.getAllCategories().filter {
            $0.name == newTrackerCategoryName
        }
        
        if sameNameCategories.isEmpty {
            let newCategory = TrackerCategory(name: newTrackerCategoryName, trackers: [tracker])
            storageService.addCategory(newCategory)
        } else {
            guard let existingCategory = sameNameCategories.first else { return }
            var newTrackerList = existingCategory.trackers
            newTrackerList.append(tracker)
            let newCategory = TrackerCategory(name: newTrackerCategoryName, trackers: newTrackerList)
            storageService.removeCategory(existingCategory)
            storageService.addCategory(newCategory)
        }
        
        trackerListVC?.newTrackerAdded()
    }
}
