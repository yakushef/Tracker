//
//  ViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 27.07.2023.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    override func awakeFromNib() {
    }
}

final class TrackerListViewController: UIViewController {
    
    private let trackers = Tracker.test

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navBarSetup()
        collectionSetup()
    }
    
    @objc func addNewTracker() {
        self.show(UINavigationController(rootViewController: TrackerTypeChoiceViewController()), sender: nil)
    }
    
    func navBarSetup() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addNewTracker))
        
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "de_GE_POSIX")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        let dateButton = UIBarButtonItem(customView: datePicker)
        datePicker.maximumDate = Date()
        navigationItem.rightBarButtonItem = dateButton
        
        let search = UISearchController(searchResultsController: nil)
        search.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationController?.navigationBar.tintColor = .label
    }
    
    func collectionSetup() {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        let layout = UICollectionViewFlowLayout()
        let trackerCollection = UICollectionView(frame: frame, collectionViewLayout: layout)
        trackerCollection.translatesAutoresizingMaskIntoConstraints = false
        trackerCollection.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        trackerCollection.delegate = self
        trackerCollection.dataSource = self
        trackerCollection.register(TrackerCell.self, forCellWithReuseIdentifier: "tracker")
        view.addSubview(trackerCollection)
        trackerCollection.reloadData()
    }
}

extension TrackerListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 39) / 2
        return CGSize(width: width, height: 148)
    }
}

extension TrackerListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
}

extension TrackerListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tracker", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        cell.backgroundColor = trackers[indexPath.row].color
        return cell
    }
}

#Preview {
    let tab = MainListTabBar()
    tab.awakeFromNib()
    
    return tab
}
