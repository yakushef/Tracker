//
//  Extension DateFormatter + Weekdays.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import Foundation

enum Weekday: String {
    case sunday = "Воскресенье"
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
}

let weekDays = [Weekday.monday,
                Weekday.tuesday,
                Weekday.wednesday,
                Weekday.thursday,
                Weekday.friday,
                Weekday.saturday,
                Weekday.sunday]
