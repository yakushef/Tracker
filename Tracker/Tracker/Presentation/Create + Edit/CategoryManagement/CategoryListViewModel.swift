//
//  CategoryListViewModel.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 05.09.2023.
//

import Foundation

final class CategoryListViewModel {
    @Observable private(set) var categoryNameList: [String] = []
    
    func updateCategories() {
        let categoryList = StorageService.shared.getAllCategories()
        categoryNameList = categoryList.map { $0.name }
    }
    
    init() {
        updateCategories()
    }
}

extension CategoryListViewModel {
    func addCategory(_ categoryName: String) {
        let currentCategories = StorageService.shared.getAllCategories()
        let sameCat = currentCategories.filter {
            $0.name == categoryName
        }
        
        if sameCat.isEmpty {
            StorageService.shared.addCategory(TrackerCategory(name: categoryName, trackers: []))
        }
        
        updateCategories()
    }
}
