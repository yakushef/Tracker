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
            case "Понедельник":
                day = 0
            case "Вторник":
                day = 1
            case "Среда":
                day = 2
            case "Четверг":
                day = 3
            case "Пятница":
                day = 4
            case "Суббота":
                day = 5
            case "Воскресенье":
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
        toggle.onTintColor = .appColors.blue
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
