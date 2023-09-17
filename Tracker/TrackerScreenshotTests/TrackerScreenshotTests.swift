//
//  TrackerScreenshotTests.swift
//  TrackerScreenshotTests
//
//  Created by Aleksey Yakushev on 17.09.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {

    func testMainScreenLight() {
        let lightVC = MainListTabBar()
        lightVC.setup()
        
        assertSnapshot(matching: lightVC, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testMainScreenDark() {
        let darkVC = MainListTabBar()
        darkVC.setup()
        
        assertSnapshot(matching: darkVC, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }

}
