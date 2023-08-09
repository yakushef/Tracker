//
//  Trackers.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 02.08.2023.
//

import UIKit

final class TrackerStorageService {
    static let shared = TrackerStorageService()
    
    private var categories: Set<TrackerCategory>
    private var records: Set<TrackerRecord>
    
    init(categories: Set<TrackerCategory> = [], records: Set<TrackerRecord> = []) {
        self.categories = categories
        self.records = records
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
        print(records)
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
            categories.insert(newCategory)
        }
    }
    
    func removeCategory(_ category: TrackerCategory) {
        categories.remove(category)
    }
}

struct TrackerCategory: Hashable {
    let name: String
    let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
    let trackerID: UUID
    let date: Date
}

struct Tracker: Hashable {
    let id: UUID
    
    let title: String
    let emoji: String
    let color: UIColor
    let trackerType: type
    let timetable: [Weekday]
    var isPinned: Bool
    
    enum type {
        case singleEvent
        case habit
    }
    
    init(eventTitle: String, emoji: String, color: UIColor) {
        self.title = eventTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .singleEvent
        self.timetable = weekDays
        self.isPinned = false
        self.id = UUID()
    }
    
    init(habitTitle: String, emoji: String, color: UIColor, timetable: [Weekday]) {
        self.title = habitTitle
        self.emoji = emoji
        self.color = color
        self.trackerType = .habit
        self.timetable = timetable
        self.isPinned = false
        self.id = UUID()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.uuidString)
    }
    
    static let test: [Tracker] = [Tracker(habitTitle: "Mic Check 1",
                                          emoji: emojiList.randomElement() ?? "🛼",
                                          color: .colorSections.section11,
                                          timetable: [.monday, .wednesday, .friday]),
                                  Tracker(eventTitle: "Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2Check 2-1-2",
                                          emoji:  emojiList.randomElement() ?? "🎮",
                                          color: .colorSections.section13)]
}
