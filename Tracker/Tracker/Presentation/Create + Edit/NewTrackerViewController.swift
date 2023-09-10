//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    private let optionItems = [NSLocalizedString("newTracker.category", comment: "Категория"),
                               NSLocalizedString("schedule.pageTtle", comment: "Расписание")]
    
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
    
    private var scrollView = UIScrollView()
    
    private var newTrackerTitle = ""
    private var newTrackerCategoty = ""
    var newTrackerEmoji: String? = nil {
        didSet {
            checkIfReady()
        }
    }
    var newTrackerColor: UIColor? = nil {
        didSet {
            checkIfReady()
        }
    }
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
    
    private let cancelButton = UIButton(type: .system)
    private let createButton = GenericAppButton(type: .system)
    private let textErrorLabel = UILabel()
    private let textField = TrackerNameField()
    private let optionsTable = UITableView()
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    private var emojiCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    private var colorCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    
    private var textStack = UIStackView()
    private var emojiStack = UIStackView()
    private var colorStack = UIStackView()
    
    var vcMode: Mode = .new
    var trackerType: Tracker.type = .habit
    
    //MARK:  - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NewTrackerDelegate.shared.newTrackerVC = self
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        if trackerType == .habit {
            setupForHabit()
        } else {
            setupForSingleEvent()
        }
        
        addTapGestureToHideKeyboard(for: textField)
    }
    
    //MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // MARK: - ScrollView
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        // MARK: - Text Field Stack
        
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 0
        textStack.addArrangedSubview(textField)
        textStack.addArrangedSubview(textErrorLabel)
        scrollView.addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor)
        ])
        textField.clipsToBounds = true
        textField.delegate = self
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = NSLocalizedString("newTracker.titlePlaceholder", comment: "Введите название трекера")
        textField.backgroundColor = .AppColors.background
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        textErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        textErrorLabel.text = NSLocalizedString("newTracker.lengthLimit", comment: "Ограничение длины названия")
        textErrorLabel.textColor = .AppColors.red
        textErrorLabel.font = .systemFont(ofSize: 17)
        textErrorLabel.contentMode = .center
        textErrorLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            textErrorLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        textErrorLabel.isHidden = (textField.text?.count ?? 0) <= 38
        textErrorLabel.alpha = textErrorLabel.isHidden ? 0 : 1
        
        // MARK: - Options
        
        scrollView.addSubview(optionsTable)
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
        optionsTable.backgroundColor = .AppColors.background
        
        optionsTable.dataSource = self
        optionsTable.delegate = self
        optionsTable.register(UITableViewCell.self, forCellReuseIdentifier: "options item")
        optionsTable.isUserInteractionEnabled = true
        
        // MARK: - Emoji
        
        scrollView.addSubview(emojiStack)
        emojiStack.translatesAutoresizingMaskIntoConstraints = false
        emojiStack.axis = .vertical
        
        NSLayoutConstraint.activate([emojiStack.topAnchor.constraint(equalTo: optionsTable.bottomAnchor, constant: 32),
                                     emojiStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                                     emojiStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)])
        
        emojiStack.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([emojiLabel.topAnchor.constraint(equalTo: emojiStack.topAnchor)])
        emojiLabel.text = NSLocalizedString("newTracker.emoji", comment: "Emoji")
        emojiLabel.font = .boldSystemFont(ofSize: 19)
        
        emojiCollection = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        emojiStack.addSubview(emojiCollection)
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.delegate = self
        emojiCollection.dataSource = self
        emojiCollection.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        emojiCollection.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        let height = view.frame.width - 36
        NSLayoutConstraint.activate([
            emojiCollection.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollection.bottomAnchor.constraint(equalTo: emojiStack.bottomAnchor, constant: -24),
            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emojiCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emojiCollection.heightAnchor.constraint(equalToConstant: height/2)
        ])
        
        // MARK: - Colors
        
        scrollView.addSubview(colorStack)
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        colorStack.axis = .vertical
        NSLayoutConstraint.activate([colorStack.topAnchor.constraint(equalTo: emojiStack.bottomAnchor, constant: 16),
                                     colorStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
                                     colorStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28)])
        colorStack.addSubview(colorLabel)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([colorLabel.topAnchor.constraint(equalTo: colorStack.topAnchor)])
        colorLabel.font = .boldSystemFont(ofSize: 19)
        colorLabel.text = NSLocalizedString("newTracker.color", comment: "Цвет")
        
        colorStack.addSubview(colorCollection)
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.dataSource = self
        colorCollection.delegate = self
        colorCollection.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        colorCollection.contentInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        NSLayoutConstraint.activate([
            colorCollection.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorCollection.bottomAnchor.constraint(equalTo: colorStack.bottomAnchor, constant: -24),
            colorCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            colorCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            colorCollection.heightAnchor.constraint(equalToConstant: height/2)
        ])
        
    
        // MARK: - Buttons
        
        let buttonStack = UIStackView()
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
        scrollView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 8
        
        NSLayoutConstraint.activate([
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            buttonStack.topAnchor.constraint(equalTo: colorStack.bottomAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
        
        let createButtonTitle = NSLocalizedString("buttons.create", comment: "Создать")
        createButton.setTitle(createButtonTitle, for: .normal)
        createButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        createButton.switchActiveState(isActive: isReady)
        
        let cancelButtonTitle = NSLocalizedString("buttons.cancel", comment: "Отмена")
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.AppColors.red.cgColor
        cancelButton.clipsToBounds = true
        cancelButton.layer.cornerRadius = 16
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        cancelButton.setTitleColor(.AppColors.red, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Methods
    
    func updateDays() {
        optionsTable.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
    }

    func updateCategory() {
        optionsTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    @objc func addButtonTapped() {
        NewTrackerDelegate.shared.setTrackerTitle(to: textField.text ?? "")
        NewTrackerDelegate.shared.createNewTracker()
        
        let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        guard let rootVC = window?.rootViewController as? UITabBarController,
              let tabBarVCs = rootVC.viewControllers,
              let navVC = tabBarVCs.first as? UINavigationController,
              let presentingVC = navVC.viewControllers.first as? TrackerListViewController else { return }

        presentingVC.dismiss(animated: true, completion: {
            self.dismiss(animated: true)
        })
    }
    
    @objc func cancelButtonTapped() {
        NewTrackerDelegate.shared.wipeAllTrackerInfo()
        dismiss(animated: true)
    }
    
    func setupForHabit() {
        navigationItem.title = NSLocalizedString("newTracker.habit", comment: "Новая привычка")
    }
    
    func setupForSingleEvent() {
        navigationItem.title = NSLocalizedString("newTracker.event", comment: "Новое нерегулярное событие")
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
        if isReady && !scheduledDays.isEmpty && !category.isEmpty && newTrackerColor != nil && newTrackerEmoji != nil {
            createButton.switchActiveState(isActive: true)
        } else {
            createButton.switchActiveState(isActive: false)
        }
    }
}

//MARK: - Table View Delegate

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

//MARK: - Table View Data Source

extension NewTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerType == .habit ? 2 : 1
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
            if category != nil {
                cell.textLabel?.numberOfLines = 0
            } else {
                cell.textLabel?.numberOfLines = 1
            }
            let titleString = NSMutableAttributedString(string: titleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label])
            let subtitleString = NSMutableAttributedString(string: subtitleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.AppColors.gray])
            titleString.append(subtitleString)
            cell.textLabel?.attributedText = titleString
        }
        
        if indexPath.row == 1 {
            let titleText = "\(optionItems[indexPath.row])\n"
            var subtitleText = ""
            if !activeDays.isEmpty {
                cell.textLabel?.numberOfLines = 0
            } else {
                cell.textLabel?.numberOfLines = 1
            }
            var newDays: [String] = []
            
            for day in weekDays {
                if activeDays.contains(day) {
                    switch day {
                    case .monday:
                        newDays.append(NSLocalizedString("schedule.monday.short", comment: "Пн"))
                    case .tuesday:
                        newDays.append(NSLocalizedString("schedule.tuesday.short", comment: "Вт"))
                    case .wednesday:
                        newDays.append(NSLocalizedString("schedule.wednesday.short", comment: "Ср"))
                    case .thursday:
                        newDays.append(NSLocalizedString("schedule.thursday.short", comment: "Чт"))
                    case .friday:
                        newDays.append(NSLocalizedString("schedule.friday.short", comment: "Пт"))
                    case .saturday:
                        newDays.append(NSLocalizedString("schedule.saturday.short", comment: "Сб"))
                    case .sunday:
                        newDays.append(NSLocalizedString("schedule.sunday.short", comment: "Вс"))
                    }
                }
            }
            
            let everyday = NSLocalizedString("schedule.everyday", comment: "All day every day")
            subtitleText = newDays.count == 7 ? everyday : newDays.joined(separator: ", ")
            
            let titleString = NSMutableAttributedString(string: titleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.label])
            let subtitleString = NSMutableAttributedString(string: subtitleText, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.AppColors.gray])
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

//MARK: - Text Field Delegate

extension NewTrackerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewTrackerViewController {
    @objc private func textFieldDidChange() {
        isReady = (textField.text?.count ?? 0) <= 38
        if let text = textField.text,
           text.isEmpty {
            isReady = false
        }
    }
}

//MARK: - Collection View Delegates

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollection {
            return emojiList.count
        } else if collectionView == colorCollection {
            return sectionColors.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == emojiCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.setEmoji(emojiList[indexPath.row])
            cell.awakeFromNib()
            return cell
        } else if collectionView == colorCollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.setColor(sectionColors[indexPath.row])
            cell.awakeFromNib()
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            NewTrackerDelegate.shared.setTrackerEmoji(to: emojiList[indexPath.row])
        } else if collectionView == colorCollection {
            NewTrackerDelegate.shared.setTrackerColor(to: sectionColors[indexPath.row])
        }
    }
}

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right) / 6
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

// MARK: - Mode

extension NewTrackerViewController {
    public enum Mode {
        case new
        case edit
    }
}
