//
//  StorageService.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 02.08.2023.
//

import UIKit

protocol StorageServiceProtocol: AnyObject {
    var trackerStorage: TrackerStoreProtocol { get }
    var recordStorage: RecordStoreProtocol { get }
    var categoryStorage: CategoryStoreProtocol { get }
    
    func addTracker(_ tracker: Tracker, categoryName: String)
    func getAllCategories() -> [TrackerCategory]
    func getTrackers(for category: TrackerCategoryCoreData) -> [Tracker]
    func getRecords(date: Date) -> [TrackerRecord]
}

final class StorageService {
    static let shared = StorageService()
    static let didChageCompletedTrackers = Notification.Name(rawValue: "CompletedTrackersDidChange")
    static let didUpdateCategories = Notification.Name(rawValue: "CategoriesDidUpdate")
    
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
    
    init(categories: Set<TrackerCategory> = [], records: Set<TrackerRecord> = []) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.categoryStorage = CategoryStore(context: context)
        self.trackerStorage = TrackerStore()
        self.recordStorage = RecordStore()
        
        self.categories = categories
        self.records = records
        
        self.categoryStorage.storageService = self
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
    
    
    func addCategory(_ newCategory: TrackerCategory) {
        let sameCategory = categories.filter {
            $0.name == newCategory.name
        }
        
        if sameCategory.isEmpty {
            categoryStorage.addCategory(category: newCategory)
            //categories.insert(newCategory)
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

extension StorageService: StorageServiceProtocol {
    func addTracker(_ tracker: Tracker, categoryName: String) {
        guard let categoryCD = categoryStorage.getCategory(named: categoryName) else { return }
        
        trackerStorage.addTracker(tracker, categoryCD: categoryCD)
    }
    
    func getAllCategories() -> [TrackerCategory] {
        let updatedCategories = categoryStorage.getAllCategories()
        categories = Set(updatedCategories)
        return updatedCategories
    }
    
    func getTrackers(for category: TrackerCategoryCoreData) -> [Tracker] {
        trackerStorage.getTrackers(category: category)
    }
}

extension StorageService: CategoryStoreDelegate {
    func categoryStoreDidUpdate() {
        NotificationCenter.default.post(Notification(name: StorageService.didUpdateCategories,
                                                     object: nil))
    }
}
