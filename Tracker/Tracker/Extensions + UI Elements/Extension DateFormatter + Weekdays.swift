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
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    func convertToString() -> String {
        var dayString = ""
        switch self {
        case .monday:
            dayString = NSLocalizedString("schedule.monday.full", comment: "Понедельник")
        case .tuesday:
            dayString = NSLocalizedString("schedule.tuesday.full", comment: "Вторник")
        case .wednesday:
            dayString = NSLocalizedString("schedule.wednesday.full", comment: "Среда")
        case .thursday:
            dayString = NSLocalizedString("schedule.thursday.full", comment: "Четверг")
        case .friday:
            dayString = NSLocalizedString("schedule.friday.full", comment: "Пятница")
        case .saturday:
            dayString = NSLocalizedString("schedule.saturday.full", comment: "Суббота")
        case .sunday:
            dayString = NSLocalizedString("schedule.sunday.full", comment: "Воскресенье")
        }
        return dayString
    }
    
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
    
    static func convertFromCD(_ weekdaysCD: TrackerScheduleCoreData) -> [Weekday] {
        var weekdays: [Weekday] = []
        if weekdaysCD.monday {
            weekdays.append(.monday)
        }
        if weekdaysCD.tuesday {
            weekdays.append(.tuesday)
        }
        if weekdaysCD.wednesday {
            weekdays.append(.wednesday)
        }
        if weekdaysCD.thursday {
            weekdays.append(.thursday)
        }
        if weekdaysCD.friday {
            weekdays.append(.friday)
        }
        if weekdaysCD.saturday {
            weekdays.append(.saturday)
        }
        if weekdaysCD.sunday {
            weekdays.append(.sunday)
        }
        return weekdays
    }
}

let weekDays = Weekday.allCases
