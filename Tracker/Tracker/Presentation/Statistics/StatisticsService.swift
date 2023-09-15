//
//  StatisticsService.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 15.09.2023.
//

import Foundation

protocol StatisticsServiceProtocol {
    func getCompletedTrackersCount() -> Int
    func getAvegageTrackerCont() -> Int
    func getBestDayTrackerCount() -> Int
    func getIdealDaysCount() -> Int
}

final class StatisticsService: StatisticsServiceProtocol {
    private let storage = StorageService.shared
    
    private let testArray = [128, 256, 64, 32, 512, 16, 1024, 8]
    
    func getCompletedTrackersCount() -> Int {
        return storage.getCompletedTrackers().count //testArray.randomElement() ?? 0
    }
    
    func getAvegageTrackerCont() -> Int {
        return testArray.randomElement() ?? 0
    }
    
    func getBestDayTrackerCount() -> Int {
        return testArray.randomElement() ?? 0
    }
    
    func getIdealDaysCount() -> Int {
        return testArray.randomElement() ?? 0
    }
}
