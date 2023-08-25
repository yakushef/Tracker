//
//  Extension DateFormatter + Weekdays.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import Foundation

var dayFormatter: DateComponentsFormatter = { let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day]
    formatter.unitsStyle = .full
    formatter.maximumUnitCount = 1
    formatter.calendar?.locale = Locale(identifier: "ru_RU")
    return formatter
}()

enum Weekday: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    func convertToCalendarWeekday() -> Int {
        var day = 0
        switch self {
        case .monday:
            day = 2
        case .tuesday:
            day = 3
        case .wednesday:
            day = 4
        case .thursday:
            day = 5
        case .friday:
            day = 6
        case .saturday:
            day = 7
        case .sunday:
            day = 1
        }
        return day
    }
}

let weekDays = Weekday.allCases
