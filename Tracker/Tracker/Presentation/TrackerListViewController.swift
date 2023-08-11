//
//  ViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 27.07.2023.
//

import UIKit

final class TrackerListViewController: UIViewController {
    
    private var trackers: [Tracker] = []
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    var trackerCollection: UICollectionView!
    private var filterButton: UIButton!
    private var placeholder = UIView()
    private let datePicker = UIDatePicker()
    private let search = UISearchController(searchResultsController: nil)
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        updateCategories()
        navBarSetup()
        collectionSetup()
        checkVisibility()
    }
    
    // MARK: - UI Setup
    
    func navBarSetup() {
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "AddTracker"), style: .plain, target: self, action: #selector(addNewTracker))
        
        datePicker.locale = Locale(identifier: "ru_DE_POSIX")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let dateButton = UIBarButtonItem(customView: datePicker)
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(updateVisibleCategories), for: .valueChanged)
        datePicker.tintColor = .appColors.blue
        navigationItem.rightBarButtonItem = dateButton
        
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.placeholder = "Поиск"
        search.searchBar.delegate = self
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    func collectionSetup() {
        placeholder = EmptyTablePlaceholder(type: .tracker, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
        
        let frame = view.safeAreaLayoutGuide.layoutFrame
        let layout = UICollectionViewFlowLayout()
        trackerCollection = UICollectionView(frame: frame, collectionViewLayout: layout)
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self
        trackerCollection.register(TrackerTypeHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        trackerCollection.register(TrackerCell.self, forCellWithReuseIdentifier: "tracker")
        view.addSubview(trackerCollection)
        trackerCollection.reloadData()
        
        filterButton = GenericAppButton(type: .system)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.backgroundColor = .appColors.blue
        filterButton.setTitle("Фильтры", for: .normal)
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
        if let srarchText = search.searchBar.text,
           !srarchText.isEmpty {
            filterButton.isHidden = true
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .search, frame: view.safeAreaLayoutGuide.layoutFrame)
            view.addSubview(placeholder)
        } else {
            filterButton.isHidden = visibleCategories.isEmpty
            placeholder.removeFromSuperview()
            placeholder = EmptyTablePlaceholder(type: .tracker, frame: view.safeAreaLayoutGuide.layoutFrame)
            view.addSubview(placeholder)
        }
        
        placeholder.isHidden = !visibleCategories.isEmpty
        trackerCollection.isHidden = visibleCategories.isEmpty
    }
    
    // MARK: - Navigation
    
    @objc func addNewTracker() {
        self.show(UINavigationController(rootViewController: TrackerTypeChoiceViewController()), sender: nil)
    }
    
    @objc func filterButtonTapped() {
        let filterVC = FilterViewController()
        show(UINavigationController(rootViewController: filterVC), sender: nil)
    }
    
    @objc func updateForDay() {
        visibleCategories = []
        updateCategories()
        let nonEmptyCategories = categories.filter {
            !$0.trackers.isEmpty
        }
//        print("non empty \(nonEmptyCategories)")
        for category in nonEmptyCategories {
            let calendar = Calendar(identifier: .gregorian)
            let weekday = calendar.component(.weekday, from: datePicker.date)
            let todayTrackers = category.trackers.filter {
                let trackerWeekdays = $0.timetable.map { $0.convertToCalendarWeekday() }
                return trackerWeekdays.contains(weekday)
            }
            visibleCategories.append(TrackerCategory(name: category.name, trackers: todayTrackers))
        }
//        print("visibleCategories \(visibleCategories)")
        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
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
        
        visibleCategories = visibleCategories.filter {
            !$0.trackers.isEmpty
        }
        
        checkVisibility()
        trackerCollection.reloadData()
    }
    
    func updateCategories() {
        categories = TrackerStorageService.shared.getAllCategories()
    }
    
    func newTrackerAdded(tracker: Tracker, category: String) {
        trackers.append(tracker)
        
        let sameNameCategories = TrackerStorageService.shared.getAllCategories().filter {
            $0.name == category
        }
        
        if sameNameCategories.isEmpty {
            let newCategory = TrackerCategory(name: category, trackers: [tracker])
            TrackerStorageService.shared.addCategory(newCategory)
        } else {
            guard let existingCategory = sameNameCategories.first else { return }
            var newTrackerList = existingCategory.trackers
            newTrackerList.append(tracker)
            let newCategory = TrackerCategory(name: category, trackers: newTrackerList)
            TrackerStorageService.shared.removeCategory(existingCategory)
            TrackerStorageService.shared.addCategory(newCategory)
        }
        updateVisibleCategories()
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
}

extension TrackerListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? TrackerTypeHeader else {
                return UICollectionReusableView()
            }
            header.label.text = visibleCategories[indexPath.section].name
            return header
        } else {
            return UICollectionReusableView()
        }
    }
}

    // MARK: - UICollectionViewDataSource

extension TrackerListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tracker", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        cell.configureCell(with: tracker, date: datePicker.date)
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension TrackerListViewController: UISearchBarDelegate {

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        updateVisibleCategories()
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateVisibleCategories()
    }
}

    //MARK: - Preview

#Preview {
    let tab = MainListTabBar()
    tab.awakeFromNib()
    
    return tab
}
