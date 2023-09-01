//
//  CategoryStore.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 30.08.2023.
//

import CoreData
import UIKit

enum CategoryError: Error {
    case categoryDecodingError
    case categoryEncodingError
}

protocol CategoryStoreProtocol: AnyObject {
    var storageService: StorageServiceProtocol? { get set }
    func getAllCategories() -> [TrackerCategory]
    func getCategory(named name: String) -> TrackerCategoryCoreData?
    func addCategory(category: TrackerCategory)
}

protocol CategoryStoreDelegate: AnyObject {
    func categoryStoreDidUpdate()
}

final class CategoryStore: NSObject, CategoryStoreProtocol {
    
    private let context: NSManagedObjectContext
    private var controller: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    weak var delegate: CategoryStoreDelegate?
    weak var storageService: StorageServiceProtocol?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.controller = controller
        try? controller.performFetch()
    }
    
    func addCategory(category: TrackerCategory) {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = category.name
        newCategory.trackers = []
        try? context.save()
    }
    
    //TODO: - checkIfEmptyAndRemove
    
    func getCategory(named name: String) -> TrackerCategoryCoreData? {
        try? controller?.performFetch()
        let category = controller?.fetchedObjects?.filter({
            $0.title == name
        })
        return category?.first
    }
    
    func convertCategoryFromCoreData(_ categoryCD: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = categoryCD.title else { throw CategoryError.categoryDecodingError }
        let trackers = storageService?.getTrackers(for: categoryCD)
        let newCategory = TrackerCategory(name: title, trackers: trackers ?? [])
        return newCategory
    }
    
    func getAllCategories() -> [TrackerCategory] {
        try? controller?.performFetch()
        guard let objects = controller?.fetchedObjects,
              let categories = try? objects.map({
                  try convertCategoryFromCoreData($0)
              }) else {
                  return []
              }
        return categories
    }
}

extension CategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //попробовать просто вызвать апдейт у делегата и не забыть обновить полный список во вьюконтроллере
        delegate?.categoryStoreDidUpdate()
    }
}
