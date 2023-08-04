//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class TrackerNameField: UITextField {
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 38))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 38))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: self.bounds.width - 38, bottom: 0, right: 16))
    }
}

class NewTrackerViewController: UIViewController {
    
    private let optionItems = ["Категория", "Расписание"]
    
    public enum Mode {
        case new
        case edit
    }
    
    let cancelButton = UIButton(type: .system)
    let createButton = UIButton(type: .system)
    
    let textField = TrackerNameField()
    let optionsTable = UITableView()
    
    var vcMode: Mode = .new
    var trackerType: Tracker.type = .habit

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        if trackerType == .habit {
            setupForHabit()
        } else {
            setupForSingleEvent()
        }
        
        if vcMode == .new {
            setupForNewTracker()
        } else {
            setuoForEditing()
        }
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .appColors.backgroundDay
        textField.clearButtonMode = .whileEditing
        
        view.addSubview(optionsTable)
        optionsTable.translatesAutoresizingMaskIntoConstraints = false
        var tableHeight: CGFloat
        if trackerType == .habit {
            tableHeight = 150
        } else {
            tableHeight = 75
        }
        NSLayoutConstraint.activate([
            optionsTable.heightAnchor.constraint(equalToConstant: tableHeight),
            optionsTable.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24),
            optionsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            optionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        optionsTable.clipsToBounds = true
        optionsTable.layer.cornerRadius = 16
        optionsTable.isScrollEnabled = false
        optionsTable.backgroundColor = .appColors.backgroundDay
        
        optionsTable.dataSource = self
        optionsTable.delegate = self
        optionsTable.register(UITableViewCell.self, forCellReuseIdentifier: "options item")
    
        let buttonStack = UIStackView()
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        
        NSLayoutConstraint.activate([
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        
        createButton.backgroundColor = .appColors.blackDay
        createButton.clipsToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        createButton.tintColor = .appColors.whiteDay
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.appColors.red.cgColor
        cancelButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.appColors.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func setupForHabit() {
        navigationItem.title = "Новая привычка"
    }
    
    func setupForSingleEvent() {
        navigationItem.title = "Новое нерегулярное событие"
    }
    
    func setupForNewTracker() {
        
    }
    
    func setuoForEditing() {
        
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let catVC = CategoryListViewController()
            show(UINavigationController(rootViewController: catVC), sender: self)
        }
        
        if indexPath.row == 1 {
            let timetableVC = TimetableViewController()
            show(UINavigationController(rootViewController: timetableVC), sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if trackerType == .habit {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "options item", for: indexPath)
        cell.textLabel?.text = optionItems[indexPath.row]
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    
        return cell
    }
    
    
}

#Preview {
    return UINavigationController(rootViewController: NewTrackerViewController())
}
