//
//  TimetableCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 25.08.2023.
//

import UIKit

final class TimetableCell: UITableViewCell {
    
    weak var delegate: TimetableCellDelegate?
    
    var isChosen: Bool = false {
        didSet {
            var day = 0
            switch textLabel?.text {
            case NSLocalizedString("schedule.monday.full", comment: "Понедельник"):
                day = 0
            case NSLocalizedString("schedule.tuesday.full", comment: "Вторник"):
                day = 1
            case NSLocalizedString("schedule.wednesday.full", comment: "Среда"):
                day = 2
            case NSLocalizedString("schedule.thursday.full", comment: "Четверг"):
                day = 3
            case NSLocalizedString("schedule.friday.full", comment: "Пятница"):
                day = 4
            case NSLocalizedString("schedule.saturday.full", comment: "Суббота"):
                day = 5
            case NSLocalizedString("schedule.sunday.full", comment: "Воскресенье"):
                day = 6
            default:
                return
            }
            delegate?.dayDidChange(to: isChosen, day: day)
        }
    }
    var toggle = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setupUI() {
        addSubview(toggle)
        
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = isChosen
        toggle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        toggle.onTintColor = .AppColors.blue
        toggle.addTarget(self, action: #selector(toggleSwitched), for: .valueChanged)
    }
    
    @objc private func toggleSwitched() {
        isChosen = toggle.isOn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

protocol TimetableCellDelegate: AnyObject {
    func dayDidChange(to: Bool,day: Int)
}
