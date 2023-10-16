//
//  TrackerScreenshotTests.swift
//  TrackerScreenshotTests
//
//  Created by Aleksey Yakushev on 17.09.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class AnalyticsServiceStub: AnalyticsServiceProtocol {
    func screenOpened(_ screenName: String) {
        
    }
    
    func screenClosed(_ screenName: String) {
        
    }
    
    func buttonTapped(_ button: AppMetricaReportModel.YMMItem, screen screenTitle: String) {
        
    }
}

final class TrackerScreenshotTests: XCTestCase {
    func testMainScreenLight() {
        let lightVC = MainListTabBar()
        lightVC.setup(analytics: AnalyticsServiceStub())
        
        assertSnapshot(matching: lightVC, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testMainScreenDark() {
        let darkVC = MainListTabBar()
        darkVC.setup(analytics: AnalyticsServiceStub())
        
        assertSnapshot(matching: darkVC, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
