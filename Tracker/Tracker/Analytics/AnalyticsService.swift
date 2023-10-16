//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 17.09.2023.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticsServiceProtocol: AnyObject {
    func screenOpened(_ screenName: String)
    func screenClosed(_ screenName: String)
    func buttonTapped(_ button: AppMetricaReportModel.YMMItem, screen screenTitle: String)
}

final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    
    private init() {
        
    }
    
    func screenOpened(_ screenName: String) {
        makeReport(event: .open, screenTitle: screenName)
    }
    
    func screenClosed(_ screenName: String) {
        makeReport(event: .close, screenTitle: screenName)
    }
    
    func buttonTapped(_ button: AppMetricaReportModel.YMMItem, screen screenTitle: String) {
        makeReport(event: .click, screenTitle: screenTitle, item: button)
    }
    
    private func makeReport(event: AppMetricaReportModel.YMMEvent,
                            screenTitle: String,
                            item: AppMetricaReportModel.YMMItem? = nil) {
        var params : [AnyHashable : Any] = [:]
        
        switch event {
        case .click:
            guard let item else { return }
            params = ["screen": screenTitle, "item" : item.rawValue]
        default:
            params = ["screen": screenTitle]
        }
        
        print("Reporting \(event) with \(params)")
        
        YMMYandexMetrica.reportEvent(event.rawValue,
                                     parameters: params,
                                     onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
