//
//  TimetableViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
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

final class TimetableViewController: UIViewController {

    let weekDaysTable = UITableView()
    let doneButton = GenericAppButton(type: .system)
    
    var activeDays = Set<Weekday>() {
        didSet {
            doneButton.switchActiveState(isActive: !activeDays.isEmpty)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Расписание"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(weekDaysTable)
        weekDaysTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekDaysTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            weekDaysTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            weekDaysTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            weekDaysTable.heightAnchor.constraint(equalToConstant: 75 * 7)
        ])
        weekDaysTable.clipsToBounds = true
        weekDaysTable.layer.cornerRadius = 16
        weekDaysTable.isScrollEnabled = false
        weekDaysTable.backgroundColor = .appColors.background
        weekDaysTable.tableHeaderView = UIView()
        
        weekDaysTable.dataSource = self
        weekDaysTable.delegate = self
        weekDaysTable.register(TimetableCell.self, forCellReuseIdentifier: "week day")
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.switchActiveState(isActive: !activeDays.isEmpty)
    }
    
    @objc private func doneButtonTapped() {
        for i in 0...6 {
            let indexPath = IndexPath(row: i, section: 0)
            if let cell = weekDaysTable.cellForRow(at: indexPath) as? TimetableCell {
                if cell.toggle.isOn {
                    activeDays.insert(weekDays[i])
                } else {
                    activeDays.remove(weekDays[i])
                }
            }
        }
        
        NewTrackerDelegate.shared.setTrackerSchedule(to: activeDays)
        dismiss(animated: true)
    }
}

extension TimetableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension TimetableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "week day", for: indexPath) as? TimetableCell else {
            return UITableViewCell()
        }
        cell.isChosen = activeDays.contains(weekDays[indexPath.row])
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.delegate = self
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.setupUI()
        
        let weekday = weekDays[indexPath.row].rawValue
        cell.textLabel?.text = weekday
        return cell
    }
}

extension TimetableViewController: TimetableCellDelegate {
    func dayDidChange(to isChosen: Bool, day: Int) {
        if isChosen {
            activeDays.insert(weekDays[day])
        } else {
            activeDays.remove(weekDays[day])
        }
    }
}
