//
//  Trackers.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 02.08.2023.
//

import UIKit

//MARK: - Tracker Storage Service

final class TrackerStorageService {
    static let shared = TrackerStorageService()
    static let didChageCompletedTrackers = Notification.Name(rawValue: "CompletedTrackersDidChange")
    
    private var categories: Set<TrackerCategory>
    private var records: Set<TrackerRecord> {
        didSet {
            NotificationCenter.default.post(Notification(name: TrackerStorageService.didChageCompletedTrackers, object: Array(self.records)))
        }
    }
    
    init(categories: Set<TrackerCategory> = [], records: Set<TrackerRecord> = []) {
        self.categories = categories
        self.records = records
    }
    
    func getRecords(date: Date) -> [TrackerRecord] {
        var thisDayRecords: [TrackerRecord] = []
        for record in records {
            if Calendar.current.isDate(record.date, inSameDayAs: date) {
                thisDayRecords.append(record)
            }
        }
        
        return thisDayRecords
    }
    
    func getRecords(for id: UUID) -> [TrackerRecord] {
        var foundRecords: [TrackerRecord] = []
        for record in records {
            if record.trackerID == id {
                foundRecords.append(record)
            }
        }
        return foundRecords
    }
    
    func addRecord(_ record: TrackerRecord) {
        records.insert(record)
    }
    
    func removeRecord(_ record: TrackerRecord) {
        let calendar = Calendar.current
        let newRecords = records.filter { !calendar.isDate($0.date, inSameDayAs: record.date)}
        records = newRecords
    }
    
    func getAllCategories() -> [TrackerCategory] {
        return Array(categories)
    }
    
    func addCategory(_ newCategory: TrackerCategory) {
        let sameCategory = categories.filter {
            $0.name == newCategory.name
        }
        
        if sameCategory.isEmpty {
            categories.insert(newCategory)
        } else {
            guard let oldCat = sameCategory.first else { return }
            var allTrackers = newCategory.trackers
            allTrackers.append(contentsOf: oldCat.trackers)
            let updatedCat = TrackerCategory(name: newCategory.name, trackers: allTrackers)
            categories.remove(oldCat)
            categories.insert(updatedCat)
        }
    }
    
    func removeCategory(_ category: TrackerCategory) {
        categories.remove(category)
    }
}

//MARK: - Tracker Category

struct TrackerCategory: Hashable {
    let name: String
    let trackers: [Tracker]
}

//MARK: - Tracker Record

struct TrackerRecord: Hashable {
    let trackerID: UUID
    let date: Date
}

//MARK: - Tracker

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
    
    init(eventTitle: String, emoji: String, color: UIColor, isPinned: Bool = false) {
        self.title = eventTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .singleEvent
        self.timetable = weekDays
        self.isPinned = isPinned
        self.id = UUID()
    }
    
    init(habitTitle: String, emoji: String, color: UIColor, timetable: [Weekday], isPinned: Bool = false) {
        self.title = habitTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .habit
        self.timetable = timetable
        self.isPinned = isPinned
        self.id = UUID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
}
