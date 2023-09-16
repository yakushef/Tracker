//
//  ViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 27.07.2023.
//

import UIKit

final class TrackerListViewController: UIViewController {
    
    private var trackers: [Tracker] = []
    private var pinnedTrackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private var trackerCollection = UICollectionView(frame: CGRect(),
                                                     collectionViewLayout: UICollectionViewLayout())
    private var filterButton = UIButton()
    private var placeholder = UIView()
    private let datePicker = UIDatePicker()
    private let search = UISearchController(searchResultsController: nil)
    
    private var appliedFilter: Filter = .all
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NewTrackerDelegate.shared.trackerListVC = self
        
        NotificationCenter.default.addObserver(forName: StorageService.didChageCompletedTrackers,
                                               object: nil,
                                               queue: .main,
                                               using: { [weak self] _ in
            guard let self else { return }
            
            completedTrackers = StorageService.shared.getRecords(date: datePicker.date)
        })
        
        NotificationCenter.default.addObserver(forName: StorageService.didUpdateCategories,
                                               object: nil,
                                               queue: .main,
                                               using: { [weak self] _ in
            self?.updateVisibleCategories()
        })
        
        view.backgroundColor = .AppColors.white
        
        updateVisibleCategories()
        navBarSetup()
        collectionSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkVisibility()
    }
    
    // MARK: - UI Setup
    
    private func navBarSetup() {
        let title = NSLocalizedString("trackerPage.title", comment: "Трекеры")
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddTracker"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(addNewTracker))
        
        datePicker.locale = Locale(identifier: "ru_DE_POSIX")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let dateButton = UIBarButtonItem(customView: datePicker)
        datePicker.maximumDate = Date()
        datePicker.addTarget(self,
                             action: #selector(updateVisibleCategories),
                             for: .valueChanged)
        datePicker.tintColor = .AppColors.blue
        datePicker.overrideUserInterfaceStyle = .light
        for subview in datePicker.subviews {
            subview.backgroundColor = .AppColors.datePickerBackground
            subview.layer.cornerRadius = 8
            subview.clipsToBounds = true
            for subsubview in subview.subviews {
                if let subsubview = subsubview as? UILabel {
                    subsubview.backgroundColor = .clear
                } else {
                    subsubview.subviews.first?.isHidden = true
                }
            }
        }
        
        navigationItem.rightBarButtonItem = dateButton

        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.placeholder = NSLocalizedString("search", comment: "Поиск")
        search.searchBar.delegate = self
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    func collectionSetup() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        let layout = UICollectionViewFlowLayout()
        trackerCollection = UICollectionView(frame: frame, collectionViewLayout: layout)
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self
        trackerCollection.register(TrackerCatHeader.self,
                                   forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                   withReuseIdentifier: "header")
        trackerCollection.register(TrackerCell.self,
                                   forCellWithReuseIdentifier: "tracker")
        trackerCollection.backgroundColor = .clear
        view.addSubview(trackerCollection)
        trackerCollection.reloadData()
        
        filterButton = GenericAppButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .AppColors.blue
        filterButton.tintColor = .white
        let filterTitle = NSLocalizedString("filters", comment: "Фильтры")
        filterButton.setTitle(filterTitle, for: .normal)
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(filterButton)
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    func checkVisibility() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        if let srarchText = search.searchBar.text,
           !srarchText.isEmpty {
            filterButton.isHidden = true
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .search, frame: frame)
            view.addSubview(placeholder)
        } else {
            filterButton.isHidden = StorageService.shared.trackerCount < 1
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .tracker, frame: frame)
            view.addSubview(placeholder)
        }
        
        placeholder.isHidden = !visibleCategories.isEmpty || !pinnedTrackers.isEmpty
        trackerCollection.isHidden = visibleCategories.isEmpty && pinnedTrackers.isEmpty
    }
    
    // MARK: - Navigation
    
    @objc func addNewTracker() {
        self.show(UINavigationController(rootViewController: TrackerTypeChoiceViewController()), sender: nil)
    }
    
    @objc func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.appliedFilter = self.appliedFilter
        filterVC.delegate = self
        show(UINavigationController(rootViewController: filterVC), sender: nil)
    }
    
    @objc func updateForDay() {
        visibleCategories = []
        updateCategories()
        let nonEmptyCategories = categories.filter {
            !$0.trackers.isEmpty
        }

        for category in nonEmptyCategories {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: datePicker.date)
            let todayTrackers = category.trackers.filter {
                let trackerWeekdays = $0.timetable.map { $0.convertToCalendarWeekday() }
                return trackerWeekdays.contains(weekday)
            }
            visibleCategories.append(TrackerCategory(name: category.name, trackers: todayTrackers))
        }

        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
        completedTrackers = StorageService.shared.getRecords(date: datePicker.date)
        checkVisibility()
        trackerCollection.reloadData()
    }
    
    // MARK: - Content Updates
    
    @objc func updateVisibleCategories() {
        updateCategories()
        visibleCategories = []
        
        let nonEmptyCategories = categories.filter {
            !$0.trackers.isEmpty
        }
        
        for category in nonEmptyCategories {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: datePicker.date)
            let todayTrackers = category.trackers.filter {
                let trackerWeekdays = $0.timetable.map { $0.convertToCalendarWeekday() }
                return trackerWeekdays.contains(weekday)
            }
            visibleCategories.append(TrackerCategory(name: category.name, trackers: todayTrackers))
        }
        
        if let searchText = search.searchBar.text,
           !searchText.isEmpty {
            let searchResults: [TrackerCategory] = visibleCategories.map {
                let trackers = $0.trackers.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText)
                }
                return TrackerCategory(name: $0.name, trackers: trackers)
            }
            visibleCategories = searchResults
        }
        
        updateFiltration()
        
        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
        
        completedTrackers = StorageService.shared.getRecords(date: datePicker.date)
        
        checkVisibility()
        trackerCollection.reloadData()
    }
    
    func updateCategories() {
        pinnedTrackers = StorageService.shared.getPinnedTrackers()
        categories = StorageService.shared.getAllCategories()
    }
    
    func newTrackerAdded() {
        categories = StorageService.shared.getAllCategories()
        updateVisibleCategories()
    }
    
    func changePinForCell(indexPath: IndexPath) {
        guard let cell = trackerCollection.cellForItem(at: indexPath) as? TrackerCell else { return }
        cell.pinStatusChanged()
        updateVisibleCategories()
    }
    
    private func editTracker(_ tracker: Tracker, categoryName: String) {
        let newTrackerVC = NewTrackerViewController()
        newTrackerVC.vcMode = .edit
        newTrackerVC.trackerType = tracker.trackerType
        newTrackerVC.setupForEditing(tracker: tracker, categoryName: categoryName)
        self.show(UINavigationController(rootViewController: newTrackerVC), sender: nil)
    }
}

    // MARK: - UICollectionViewDelegate

extension TrackerListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 39) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return nil }
        
        let title = cell.isPinned ? "Открепить" : "Закрепить"
        
        let config = UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: title) { [weak self] _ in
                    self?.changePinForCell(indexPath: indexPath)
                },
                UIAction(title: "Редактировать", handler: { [weak self] _ in
                    guard let trackerCD = StorageService.shared.getTracker(trackerId: cell.cellTracker.id),
                          let cat = trackerCD.category,
                    let categoryTitle = cat.title else { return }
                    self?.editTracker(cell.cellTracker, categoryName: categoryTitle)
                }),
                UIAction(title: "Удалить", attributes: .destructive) { _ in
                    StorageService.shared.deleteTracker(id: cell.cellTracker.id)
                }
            ])
        })
        return config
    }
}

extension TrackerListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerCatHeader else {
                return UICollectionReusableView()
            }
            if pinnedTrackers.isEmpty {
                header.label.text = visibleCategories[indexPath.section].name
            } else {
                switch indexPath.section {
                case 0:
                    header.label.text = "Закрепленные"
                default:
                    header.label.text = visibleCategories[indexPath.section - 1].name
                }
            }
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension TrackerListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if pinnedTrackers.isEmpty {
            return visibleCategories.count
        } else {
            return visibleCategories.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if pinnedTrackers.isEmpty {
            return visibleCategories[section].trackers.count
        } else {
            switch section {
            case 0:
                return pinnedTrackers.count
            default:
                return visibleCategories[section - 1].trackers.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tracker", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        var tracker: Tracker
        if pinnedTrackers.isEmpty {
            tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        } else {
            switch indexPath.section {
            case 0:
                tracker = pinnedTrackers[indexPath.row]
            default:
                tracker = visibleCategories[indexPath.section - 1].trackers[indexPath.row]
            }
        }
        completedTrackers = StorageService.shared.getRecords(date: StorageService.shared.calendar.startOfDay(for: datePicker.date))
        cell.configureCell(with: tracker, date: datePicker.date)
        cell.delegate = self
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension TrackerListViewController: UISearchBarDelegate {

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        updateVisibleCategories()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateVisibleCategories()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateVisibleCategories()
    }
}

// MARK: - TrackerCellDelegate

extension TrackerListViewController: TrackerCellDelegate {
    func updatePinnedStatus(trackerID: UUID, to pinned: Bool) {
        StorageService.shared.changePinStatus(for: trackerID, to: pinned)
    }
    
    func updateRecords(with record: TrackerRecord, completion: (Bool) -> Void) {
        completedTrackers = StorageService.shared.getRecords(date: datePicker.date)
        let completedID = completedTrackers.filter {
            $0.trackerID == record.trackerID
        }
        let isRecorded = !completedID.isEmpty
        if !isRecorded {
            StorageService.shared.addRecord(record)
        } else {
            StorageService.shared.removeRecord(record)
        }
        completion(!isRecorded)
    }
}

extension TrackerListViewController: FilterDelegate {
    func filterDidChange(to filter: Filter) {
        appliedFilter = filter
        updateVisibleCategories()
    }
    
    private func updateFiltration() {
        switch appliedFilter {
        case .all:
            filterForAll()
        case .today:
            filterForToday()
        case .toDo:
            filterForToDo()
        case .done:
            filterForDone()
        }
    }
    
    private func filterForAll() {
        enableDatePicker()
    }
    
    private func filterForToday() {
        datePicker.date = Date()
        disableDatePicker()
    }
    
    private func filterForToDo() {
        enableDatePicker()
        var toDoCategories: [TrackerCategory]
        toDoCategories = visibleCategories.map { oldCategory in
            let newTrackers = oldCategory.trackers.filter {
                !checkIfDoneToday(trackerID: $0.id)
            }
            let newCategory = TrackerCategory(name: oldCategory.name, trackers: newTrackers)
            return newCategory
        }
        visibleCategories = toDoCategories
    }
    
    private func filterForDone() {
        enableDatePicker()
        var toDoCategories: [TrackerCategory]
        toDoCategories = visibleCategories.map { oldCategory in
            let newTrackers = oldCategory.trackers.filter {
                checkIfDoneToday(trackerID: $0.id)
            }
            let newCategory = TrackerCategory(name: oldCategory.name, trackers: newTrackers)
            return newCategory
        }
        visibleCategories = toDoCategories
    }
    
    private func enableDatePicker() {
        datePicker.isEnabled = true
        datePicker.alpha = 1
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = .AppColors.lightGray
    }
    
    private func disableDatePicker() {
        datePicker.isEnabled = false
        datePicker.alpha = 0.3
        datePicker.overrideUserInterfaceStyle = .dark
        datePicker.backgroundColor = .AppColors.gray
    }
    
    private func checkIfDoneToday(trackerID: UUID) -> Bool {
        let allRecords = StorageService.shared.getRecords(for: trackerID)

        var isRecorded = false

        for record in allRecords {
            let calendar = Calendar.current
            if calendar.isDate(datePicker.date, inSameDayAs: record.date) {
                isRecorded = true
            }
        }
        return isRecorded
    }
}
