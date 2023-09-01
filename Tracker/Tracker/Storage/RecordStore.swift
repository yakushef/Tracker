//
//  RecordStore.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 30.08.2023.
//

import UIKit
import CoreData

enum RecordError: Error {
    case recordEncodingFailure
    case recordDecodingFailure
}

protocol RecordStoreProtocol: AnyObject {
    var delegate: RecordStoreDelegate? { get set }
    var storageService: StorageServiceProtocol? { get set }
    
    func getAllRecords() -> [TrackerRecord]
    func addRecord(_ record: TrackerRecord)
    func removeRecord(_ record: TrackerRecord)
}

protocol RecordStoreDelegate: AnyObject {
    func recordStoreDidUpdate()
}

final class RecordStore: NSObject, RecordStoreProtocol {
    private let context: NSManagedObjectContext
    private var controller: NSFetchedResultsController<TrackerRecordCoreData>?
    
    weak var delegate: RecordStoreDelegate?
    weak var storageService: StorageServiceProtocol?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.controller = controller
    }
    
    func getAllRecords() -> [TrackerRecord] {
        var allRecords: [TrackerRecord] = []
        controller?.fetchRequest.predicate = nil
        try? controller?.performFetch()
        if let recordsCD = controller?.fetchedObjects {
            do { allRecords = try recordsCD.map {
                try recordFromCD($0)
            }
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return allRecords
    }
    
    func recordFromCD(_ recordCD: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let tracker = recordCD.tracker,
              let id = tracker.trackerId,
              let date = recordCD.date else {
            throw RecordError.recordEncodingFailure
        }
        return TrackerRecord(trackerID: id, date: date)
    }
    
    func addRecord(_ record: TrackerRecord) {
//        removeRecord(record)
        guard let tracker = storageService?.getTracker(trackerId: record.trackerID) else {
            return
        }
        let newRecordCD = TrackerRecordCoreData(context: context)
        
        newRecordCD.date = storageService?.calendar.startOfDay(for: record.date)
        newRecordCD.tracker = tracker
        try? context.save()
    }
    
    func removeRecord(_ record: TrackerRecord) {
        let recordPredicates = [
            NSPredicate(format: "%K = %@",
                        argumentArray: [#keyPath(TrackerRecordCoreData.tracker.trackerId), record.trackerID]),
            NSPredicate(format: "%K = %@",
                        argumentArray: [#keyPath(TrackerRecordCoreData.date), record.date])
        ]
        controller?.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: recordPredicates)
        do {
            try controller?.performFetch()
        } catch {
            assertionFailure(error.localizedDescription)
        }
        guard let recordToRemove = controller?.fetchedObjects?.first else { return }
        context.delete(recordToRemove)
        try? context.save()
    }
}

extension RecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //попробовать просто вызвать апдейт у делегата и не забыть обновить полный список во вьюконтроллере
        delegate?.recordStoreDidUpdate()
    }
}

//rgba(0, 123, 250, 1), rgba(70, 230, 157, 1), rgba(253, 76, 73, 1)

