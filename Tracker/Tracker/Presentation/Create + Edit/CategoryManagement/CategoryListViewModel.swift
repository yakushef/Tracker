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
