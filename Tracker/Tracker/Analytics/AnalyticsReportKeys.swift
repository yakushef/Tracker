//
//  AnalyticsReportKeys.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 17.09.2023.
//

import Foundation

public struct AppMetricaReportModel {
    enum YMMScreens: String {
        case main = "Main"
    }
    
    enum YMMEvent: String {
        case open
        case close
        case click
    }
    
    enum YMMItem: String {
        case add_track
        case track
        case filter
        case edit
        case delete
    }
}
