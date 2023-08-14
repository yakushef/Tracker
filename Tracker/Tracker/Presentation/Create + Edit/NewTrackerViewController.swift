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

    var category: String? {
        didSet {
            updateCategory()
            checkIfReady()
        }
    }
    var activeDays: Set<Weekday> = [] {
        didSet {
            updateDays()
            checkIfReady()
        }
    }
    
    private var newTrackerTitle = ""
    private var newTrackerCategoty = ""
    private var newTrackerTimetable: [Weekday] = []
    private var isReady = false {
        didSet {
            checkIfReady()
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                guard let self else { return }
                self.textErrorLabel.isHidden = (self.textField.text?.count ?? 0) <= 38
                if self.textErrorLabel.alpha == 1 {
                    self.textErrorLabel.alpha = 0
                } else {
                    self.textErrorLabel.alpha = 1
                }
            })
        }
    }
    
    public enum Mode {
        case new
        case edit
    }
    
    let cancelButton = UIButton(type: .system)
    let createButton = GenericAppButton(type: .system)
    let textErrorLabel = UILabel()
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
        
        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 0
        textStack.addArrangedSubview(textField)
        textStack.addArrangedSubview(textErrorLabel)
        view.addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 18),
            textStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -18)
        ])
        
//        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
        textField.clipsToBounds = true
        textField.delegate = self
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .appColors.background
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
//        view.addSubview(textErrorLabel)
        textErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        textErrorLabel.text = "Ограничение 38 символов"
        textErrorLabel.textColor = .appColors.red
        textErrorLabel.font = .systemFont(ofSize: 17)
        textErrorLabel.contentMode = .center
        textErrorLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            textErrorLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        textErrorLabel.isHidden = (textField.text?.count ?? 0) <= 38
        textErrorLabel.alpha = textErrorLabel.isHidden ? 0 : 1
        
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
            optionsTable.topAnchor.constraint(equalTo: textStack.bottomAnchor, constant: 24),
            optionsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            optionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        optionsTable.clipsToBounds = true
        optionsTable.layer.cornerRadius = 16
        optionsTable.isScrollEnabled = false
        optionsTable.backgroundColor = .appColors.background
        
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
        
//        createButton.backgroundColor = .appColors.black
//        createButton.clipsToBounds = true
//        createButton.layer.cornerRadius = 16
        createButton.setTitle("Создать", for: .normal)
//        createButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
//        createButton.tintColor = .appColors.white
        createButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        createButton.switchActiveState(isActive: isReady)
        
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
    
    func updateDays() {
        optionsTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }

    func updateCategory() {
        optionsTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    @objc func addButtonTapped() {
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        guard let rootVC = window?.rootViewController as? UITabBarController,
              let tabBarVCs = rootVC.viewControllers,
              let navVC = tabBarVCs.first as? UINavigationController,
              let presentingVC = navVC.viewControllers.first as? TrackerListViewController else { return }
        
        var tracker: Tracker
        switch trackerType {
        case .habit:
            var days: [Weekday] = []
            days.append(contentsOf: activeDays)
            tracker = Tracker(habitTitle: textField.text ?? "", emoji: emojiList.randomElement() ?? "🧩", color: sectionColors.randomElement() ?? .gray, timetable: days)
        case .singleEvent:
            tracker = Tracker(eventTitle: textField.text ?? "",
                              emoji: emojiList.randomElement() ?? "🧩",
                              color: sectionColors.randomElement() ?? .gray)
        }
        
        presentingVC.newTrackerAdded(tracker: tracker, category: category ?? "")
        presentingVC.dismiss(animated: true, completion: {
            presentingVC.dismiss(animated: false, completion: nil)
        })
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
    
    func checkIfReady() {
        guard let category else {
            createButton.switchActiveState(isActive: false)
            return
        }
        var scheduledDays = activeDays
        if trackerType == .singleEvent {
            scheduledDays = Set(weekDays)
        }
        if isReady && !scheduledDays.isEmpty && !category.isEmpty {
            createButton.switchActiveState(isActive: true)
        } else {
            createButton.switchActiveState(isActive: false)
        }
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
            timetableVC.activeDays = self.activeDays
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
        
        if indexPath.row == 0 {
            let titleText = "\(optionItems[indexPath.row])\n"
            let subtitleText = category ?? ""
            if category != nil { cell.textLabel?.numberOfLines = 0 } else {
                cell.textLabel?.numberOfLines = 1
            }
            let titleString = NSMutableAttributedString(string: titleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label])
            let subtitleString = NSMutableAttributedString(string: subtitleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.appColors.gray])
            titleString.append(subtitleString)
            cell.textLabel?.attributedText = titleString
        }
        
        if indexPath.row == 1 {
            let titleText = "\(optionItems[indexPath.row])\n"
            var subtitleText = ""
            if !activeDays.isEmpty { cell.textLabel?.numberOfLines = 0 } else {
                cell.textLabel?.numberOfLines = 1
            }
            var newDays: [String] = []
            
            for day in weekDays {
                if activeDays.contains(day) {
                    switch day {
                    case .monday:
                        newDays.append("Пн")
                    case .tuesday:
                        newDays.append("Вт")
                    case .wednesday:
                        newDays.append("Ср")
                    case .thursday:
                        newDays.append("Чт")
                    case .friday:
                        newDays.append("Пт")
                    case .saturday:
                        newDays.append("Сб")
                    case .sunday:
                        newDays.append("Вс")
                    }
                }
            }
            
            subtitleText = newDays.count == 7 ? "Каждый день" : newDays.joined(separator: ", ")
            
            let titleString = NSMutableAttributedString(string: titleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label])
            let subtitleString = NSMutableAttributedString(string: subtitleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.appColors.gray])
            titleString.append(subtitleString)
            cell.textLabel?.attributedText = titleString
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        newTrackerTitle = textField.text ?? ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        isReady = (textField.text?.count ?? 0) <= 38
        if let text = textField.text,
           text.isEmpty {
            isReady = false
        }
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    return UINavigationController(rootViewController: NewTrackerViewController())
}
