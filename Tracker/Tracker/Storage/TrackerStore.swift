//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 30.08.2023.
//

import UIKit
import CoreData

enum TrackerError: Error {
    case trackerDecodingError
    case trackerEncodingError
}

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

protocol TrackerStoreProtocol: AnyObject {
    var delegate: TrackerStoreDelegate? { get set }
    var storageService: StorageServiceProtocol? { get set }
    
    func addTracker(_ tracker: Tracker, categoryCD: TrackerCategoryCoreData)
    func getTrackers(category: TrackerCategoryCoreData) -> [Tracker]
    func getTracker(trackerId: UUID) -> TrackerCoreData?
    func getCompletedTrackers() -> [Tracker]
}

final class TrackerStore: NSObject, TrackerStoreProtocol {
    private let context: NSManagedObjectContext
    private var controller: NSFetchedResultsController<TrackerCoreData>?
    
    weak var delegate: TrackerStoreDelegate?
    weak var storageService: StorageServiceProtocol?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.controller = controller
    }
    
    func addTracker(_ tracker: Tracker, categoryCD: TrackerCategoryCoreData) {
        let newTracker = TrackerCoreData(context: context)
        switch tracker.trackerType {
        case .habit:
            newTracker.isHabit = true
        case .singleEvent:
            newTracker.isHabit = false
        }
        
        guard let cat = context.object(with: categoryCD.objectID) as? TrackerCategoryCoreData else {
            assertionFailure(TrackerError.trackerDecodingError.localizedDescription)
            return
        }
        
        newTracker.isPinned = tracker.isPinned
        newTracker.trackerId = tracker.id
        newTracker.title = tracker.title
        newTracker.emoji = tracker.emoji
        newTracker.schedule = convertWeekdaysToCD(tracker.timetable, context: context)
        newTracker.colorIndex = Int16(sectionColors.firstIndex(of: tracker.color) ?? 0)
        newTracker.category = cat
        newTracker.records = []

        cat.addToTrackers(newTracker)
        
        do { try context.save() }
        catch {
            assertionFailure(error.localizedDescription)
        }
    }
    
    func getTrackers(category: TrackerCategoryCoreData) -> [Tracker] {
        controller?.fetchRequest.predicate = NSPredicate(format: "%K = %@",
                        argumentArray: [#keyPath(TrackerCoreData.category), category])
        try? controller?.performFetch()
        
        guard let objects = controller?.fetchedObjects,
              let trackers = try? objects.map({
                  try convertTracker(from: $0)
              }) else {
                  return []
              }
        return trackers
    }
    
    func getTracker(trackerId: UUID) -> TrackerCoreData? {
        controller?.fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(TrackerCoreData.trackerId), trackerId])
        try? controller?.performFetch()
        
        guard let trackers = controller?.fetchedObjects else {
                  return nil
              }
        return trackers.first
    }
    
    func getCompletedTrackers() -> [Tracker] {
        controller?.fetchRequest.predicate = NSPredicate(format: "records.@count > 0")
        try? controller?.performFetch()
        
        guard let objects = controller?.fetchedObjects,
              let trackers = try? objects.map({
                  try convertTracker(from: $0)
              }) else {
                  return []
              }
        return trackers
    }
    
    private func convertTracker(from trackerCD: TrackerCoreData) throws -> Tracker {
        guard let title = trackerCD.title,
              let emoji = trackerCD.emoji,
              let weekdaysCD = trackerCD.schedule,
              let id = trackerCD.trackerId else { throw TrackerError.trackerDecodingError }
        
        if trackerCD.isHabit {
            return Tracker(habitTitle: title, emoji: emoji, color: sectionColors[Int(trackerCD.colorIndex)], timetable: Weekday.convertFromCD(weekdaysCD), id: id)
        } else {
            return Tracker(eventTitle: title, emoji: emoji, color: sectionColors[Int(trackerCD.colorIndex)], id: id)
        }
    }
    
    private func convertWeekdaysToCD(_ weekdays: [Weekday], context: NSManagedObjectContext) -> TrackerScheduleCoreData {
        let weekdaysCD = TrackerScheduleCoreData(context: context)
        let weekdaysSet = Set(weekdays)
        weekdaysCD.monday = weekdaysSet.contains(.monday)
        weekdaysCD.tuesday = weekdaysSet.contains(.tuesday)
        weekdaysCD.wednesday = weekdaysSet.contains(.wednesday)
        weekdaysCD.thursday = weekdaysSet.contains(.thursday)
        weekdaysCD.friday = weekdaysSet.contains(.friday)
        weekdaysCD.saturday = weekdaysSet.contains(.saturday)
        weekdaysCD.sunday = weekdaysSet.contains(.sunday)
        
        return weekdaysCD
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
