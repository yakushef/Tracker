//
//  StorageService.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 02.08.2023.
//

import UIKit

protocol StorageServiceProtocol: AnyObject {
    var calendar: Calendar { get }
    var trackerStorage: TrackerStoreProtocol { get }
    var recordStorage: RecordStoreProtocol { get }
    var categoryStorage: CategoryStoreProtocol { get }
    var trackerCount: Int { get }
    
    func addTracker(_ tracker: Tracker, categoryName: String)
    func getTracker(trackerId: UUID) -> TrackerCoreData?
    func getAllCategories() -> [TrackerCategory]
    func getTrackers(for category: TrackerCategoryCoreData) -> [Tracker]
    func getPinnedTrackers() -> [Tracker]
    func getRecords(date: Date) -> [TrackerRecord]
    func getCompletedTrackers() -> [Tracker]
    func changePinStatus(for trackerID: UUID, to pinned: Bool)
    func deleteTracker(id: UUID)
}

final class StorageService {
    static let shared = StorageService()
    static let didChageCompletedTrackers = Notification.Name(rawValue: "CompletedTrackersDidChange")
    static let didUpdateCategories = Notification.Name(rawValue: "CategoriesDidUpdate")
    
    var trackerCount: Int = 0
    let calendar: Calendar
    var trackerStorage: TrackerStoreProtocol
    var recordStorage: RecordStoreProtocol
    var categoryStorage: CategoryStoreProtocol
    
    private var categories: Set<TrackerCategory>
    
    private var records: Set<TrackerRecord> {
        didSet {
            NotificationCenter.default.post(Notification(name: StorageService.didChageCompletedTrackers,
                                                         object: Array(self.records)))
        }
    }
    
    private init(categories: Set<TrackerCategory> = [], records: Set<TrackerRecord> = []) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.categoryStorage = CategoryStore(context: context)
        self.trackerStorage = TrackerStore()
        self.recordStorage = RecordStore()
        
        self.categories = categories
        self.records = records
        
        self.calendar = {
            var calendar = Calendar.current
            if let timeZone = TimeZone(secondsFromGMT: 0) {
                calendar.timeZone = timeZone
            }
            return calendar
        }()
        
        self.categoryStorage.storageService = self
        self.categoryStorage.delegate = self
        self.recordStorage.storageService = self
        self.recordStorage.delegate = self
        self.trackerStorage.storageService = self
        self.trackerStorage.delegate = self
        
        self.records = Set(self.recordStorage.getAllRecords())
        self.trackerCount = trackerStorage.getTrackerCount()
    }
    
    func addCategory(_ newCategory: TrackerCategory) {
        let sameCategory = categories.filter {
            $0.name.lowercased() == newCategory.name.lowercased()
        }
        
        if sameCategory.isEmpty {
            categoryStorage.addCategory(category: newCategory)
        }
    }
}

extension StorageService: StorageServiceProtocol {
    func deleteTracker(id: UUID) {
        trackerCount = trackerStorage.getTrackerCount() - 1
        trackerStorage.deleteTracker(trackerId: id)
    }
    
    func changePinStatus(for trackerID: UUID, to pinned: Bool) {
        trackerStorage.changeTrackerPinStatus(trackerId: trackerID, pinned: pinned)
    }
    
    
    func getCompletedTrackers() -> [Tracker] {
        trackerStorage.getCompletedTrackers()
    }
    
    func addTracker(_ tracker: Tracker, categoryName: String) {
        guard let categoryCD = categoryStorage.getCategory(named: categoryName) else { return }
        trackerCount = trackerStorage.getTrackerCount() + 1
        trackerStorage.addTracker(tracker, categoryCD: categoryCD)
    }
    
    func getAllCategories() -> [TrackerCategory] {
        let updatedCategories = categoryStorage.getAllCategories()
        categories = Set(updatedCategories)
        return updatedCategories
    }
    
    func getTrackers(for category: TrackerCategoryCoreData) -> [Tracker] {
        trackerStorage.getTrackers(category: category, includePinned: false)
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
    
    func getPinnedTrackers() -> [Tracker] {
        return trackerStorage.getPinnedTrackers()
    }
    
    func getTracker(trackerId: UUID) -> TrackerCoreData? {
        return trackerStorage.getTracker(trackerId: trackerId)
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
        recordStorage.addRecord(record)
    }
    
    func removeRecord(_ record: TrackerRecord) {
        recordStorage.removeRecord(record)
    }
}

extension StorageService: CategoryStoreDelegate, TrackerStoreDelegate, RecordStoreDelegate {
    func recordStoreDidUpdate() {
        records = Set(recordStorage.getAllRecords())
    }
    
    func categoryStoreDidUpdate() {
        NotificationCenter.default.post(Notification(name: StorageService.didUpdateCategories,
                                                     object: nil))
    }
    
    func trackerStoreDidUpdate() {
        NotificationCenter.default.post(Notification(name: StorageService.didUpdateCategories,
                                                     object: nil))
    }
}

