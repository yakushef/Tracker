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
    func addTracker(_ tracker: Tracker, categoryCD: TrackerCategoryCoreData)
    func getTrackers(category: TrackerCategoryCoreData) -> [Tracker]
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
        
        let cat = context.object(with: categoryCD.objectID) as! TrackerCategoryCoreData
        
        newTracker.isPinned = tracker.isPinned
        newTracker.id = tracker.id
        newTracker.title = tracker.title
        newTracker.emoji = tracker.emoji
        newTracker.schedule = Weekday.convertToCD(tracker.timetable, context: context)
        newTracker.colorIndex = Int16(sectionColors.firstIndex(of: tracker.color) ?? 0)
        newTracker.category = cat
        newTracker.records = []
        
//        print(newTracker)
        

        cat.addToTrackers(newTracker)
//        categoryCD.addToTrackers(newTracker)
        
//        print(cat)
        
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
    
    func convertTracker(from trackerCD: TrackerCoreData) throws -> Tracker {
        guard let title = trackerCD.title,
              let emoji = trackerCD.emoji,
              let weekdaysCD = trackerCD.schedule else { throw TrackerError.trackerDecodingError }
        
        if trackerCD.isHabit {
            return Tracker(habitTitle: title, emoji: emoji, color: sectionColors[Int(trackerCD.colorIndex)], timetable: Weekday.convertFromCD(weekdaysCD))
        } else {
            return Tracker(eventTitle: title, emoji: emoji, color: sectionColors[Int(trackerCD.colorIndex)])
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //попробовать просто вызвать апдейт у делегата и не забыть обновить полный список во вьюконтроллере
        delegate?.trackerStoreDidUpdate()
    }
}
//save

//edit

//pin
