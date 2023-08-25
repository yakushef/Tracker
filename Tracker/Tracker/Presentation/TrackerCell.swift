//
//  TrackerCell.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 03.08.2023.
//

import UIKit

//MARK: - TrackerCellDelegate

protocol TrackerCellDelegate: AnyObject {
    func updatePinnedStatus()
    func updateRecords(with record: TrackerRecord, completion: (Bool) -> Void)
}

//MARK: - TrackerCell

final class TrackerCell: UICollectionViewCell {
    var cardView = UIView()
    var emojiLabel = UILabel()
    var pinImage = UIImageView()
    var titleLabel = UILabel()
    var isRecorded: Bool = false {
        didSet {
            incrementButton.setImage(buttonImage(), for: .normal)
            incrementButton.alpha = isRecorded ? 0.3 : 1
        }
    }
    private lazy var buttonImage = { [weak self] in
        guard let self else { return UIImage() }
        var image = UIImage(named: self.isRecorded ? "Recorded" : "Plus") ?? UIImage()
        return image
    }
    var allRecords: [TrackerRecord] = []
    weak var delegate: TrackerCellDelegate?
    
    var managementView = UIView()
    var incrementButton = UIButton()
    var daysLabel = UILabel()
    var cellDate = Date()
    
    var cellTracker: Tracker!
    
    override func prepareForReuse() {
        daysLabel.text = ""
        daysLabel.removeFromSuperview()
        incrementButton.removeFromSuperview()
    }
    
    //MARK: - Status for select date
    
    func checkIfRecorded() {
        allRecords = TrackerStorageService.shared.getRecords(for: cellTracker.id)

        var isNowRecorded = false

        for record in allRecords {
            let calendar = Calendar.current
            if calendar.isDate(cellDate, inSameDayAs: record.date) {
            isNowRecorded = true
            }
        }
        isRecorded = isNowRecorded
    }
    
    func configureCell(with tracker: Tracker, date: Date) {
        cellTracker = tracker
        cellDate = date
        checkIfRecorded()
        
        //MARK: - Card View
        
        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.heightAnchor.constraint(equalToConstant: 90),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor)
        ])
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.backgroundColor = tracker.color
        
        //MARK: - Pin Image
        
        pinImage.image = UIImage(named: "Pin")
        cardView.addSubview(pinImage)
        pinImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pinImage.heightAnchor.constraint(equalToConstant: 24),
            pinImage.widthAnchor.constraint(equalToConstant: 24),
            pinImage.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImage.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -4)
        ])
        
        pinImage.isHidden = !(cellTracker?.isPinned ?? false)
        
        //MARK: - Emoji
        
        cardView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12)
        ])
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.backgroundColor = .appColors.background
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.text = tracker.emoji
        
        //MARK: - Title
        
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
        ])
        titleLabel.font = .boldSystemFont(ofSize: 12)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .appColors.white
        titleLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        titleLabel.text = tracker.title
        
        //MARK: - Management
        
        addSubview(managementView)
        managementView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            managementView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            managementView.bottomAnchor.constraint(equalTo: bottomAnchor),
            managementView.leadingAnchor.constraint(equalTo: leadingAnchor),
            managementView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        //MARK: - Increment Button
        
        incrementButton = UIButton(type: .system)
        incrementButton.setImage(buttonImage(), for: .normal)
        managementView.addSubview(incrementButton)
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            incrementButton.heightAnchor.constraint(equalToConstant: 34),
            incrementButton.widthAnchor.constraint(equalToConstant: 34),
            incrementButton.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            incrementButton.trailingAnchor.constraint(equalTo: managementView.trailingAnchor, constant: -12)
        ])
        incrementButton.backgroundColor = tracker.color
        incrementButton.tintColor = .appColors.white
        incrementButton.clipsToBounds = true
        incrementButton.layer.cornerRadius = 17
        incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
        incrementButton.showsTouchWhenHighlighted = true
        
        //MARK: - Day Label
        
        daysLabel = UILabel()
        managementView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysLabel.leadingAnchor.constraint(equalTo: managementView.leadingAnchor, constant: 12),
            daysLabel.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -8),
            daysLabel.topAnchor.constraint(equalTo: managementView.topAnchor, constant: 8),
            daysLabel.bottomAnchor.constraint(equalTo: incrementButton.bottomAnchor)
        ])
        daysLabel.font = UIFont(name: "SFPro-Medium", size: 12)
        updateDay()
    }
    
    private func updateDay() {
        let daysCount = TrackerStorageService.shared.getRecords(for: cellTracker.id)
        daysLabel.text = dayFormatter.string(from: DateComponents(day: daysCount.count))
    }
    
    @objc func incrementButtonTapped() {
        let record = TrackerRecord(trackerID: cellTracker.id, date: cellDate)
        delegate?.updateRecords(with: record) { [weak self] newRecStatus in
            self?.isRecorded = newRecStatus
        }
        updateDay()
    }
}

