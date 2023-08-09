//
//  TimetableViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

final class GenericAppButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .appColors.blackDay
        self.tintColor = .appColors.whiteDay
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        self.titleLabel?.font = .boldSystemFont(ofSize: 16)
    }
    
    func switchActiveState() {
        if isEnabled {
            isEnabled = false
            backgroundColor = .appColors.gray
        } else {
            isEnabled = true
            backgroundColor = .appColors.blackDay
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

final class TimetableCell: UITableViewCell {
    
    var isChosen: Bool = false
    var toggle = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setupUI() {
        addSubview(toggle)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitched()
        toggle.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        toggle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        toggle.onTintColor = .appColors.blue
        toggle.addTarget(self, action: #selector(toggleSwitched), for: .valueChanged)
    }
    
    @objc func toggleSwitched() {
        isChosen = toggle.isOn
    }
    
    required init?(coder: NSCoder) {
        fatalError("init: coder not implemented")
    }
}

final class TimetableViewController: UIViewController {

    let weekDaysTable = UITableView()
    let doneButton = GenericAppButton(type: .system)
    
    var activeDays = Set<Weekday>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Расписание"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    func setupUI() {
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
        weekDaysTable.backgroundColor = .appColors.backgroundDay
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
        
        
    }
    
    @objc func doneButtonTapped() {
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
        
        guard let presentingNavVC = presentingViewController as? UINavigationController,
        let presentingVC = presentingNavVC.viewControllers.first as? NewTrackerViewController else { return }
        
        presentingVC.activeDays = self.activeDays
//        presentingVC.updateDays()
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
        cell.setupUI()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.accessoryType = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        let weekday = weekDays[indexPath.row].rawValue
        cell.textLabel?.text = weekday
        return cell
    }
    
    
}

#Preview {
    return UINavigationController(rootViewController: TimetableViewController())
}
