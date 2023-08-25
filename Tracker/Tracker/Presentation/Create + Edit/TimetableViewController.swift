//
//  TimetableViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        
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
