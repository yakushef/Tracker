//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 15.09.2023.
//

import Foundation

struct Statistics {
    var completedTrackerCount: Int
    var averageTrackerCount: Int
    var bestDayTrackerCount: Int
    var idealDaysCount: Int
}

final class StatisticsViewModel {
    @Observable private(set) var statistics = Statistics(completedTrackerCount: 0,
                                             averageTrackerCount: 0,
                                             bestDayTrackerCount: 0,
                                             idealDaysCount: 0)
    
    private var statisticsService: StatisticsServiceProtocol
    
    init(statisticsService: StatisticsServiceProtocol = StatisticsService()) {
        self.statisticsService = statisticsService
        
        updateStatistics()
    }
    
    func updateStatistics() {
        statistics.completedTrackerCount = statisticsService.getCompletedTrackersCount()
        statistics.averageTrackerCount = statisticsService.getAvegageTrackerCont()
        statistics.bestDayTrackerCount = statisticsService.getBestDayTrackerCount()
        statistics.idealDaysCount = statisticsService.getIdealDaysCount()
    }
}
