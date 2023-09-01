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
    private var cardView = UIView()
    private var emojiLabel = UILabel()
    private var pinImage = UIImageView()
    private var titleLabel = UILabel()
    private var isRecorded: Bool = false {
        didSet {
            incrementButton.setImage(buttonImage(), for: .normal)
        }
    }
    private lazy var buttonImage = { [weak self] in
        guard let self else { return UIImage() }
        var image = UIImage(named: self.isRecorded ? "Recorded" : "Plus") ?? UIImage()
        self.incrementButton.alpha = self.isRecorded ? 0.3 : 1
        incrementButton.layoutSubviews()
        return image
    }
    private var allRecords: [TrackerRecord] = []
    weak var delegate: TrackerCellDelegate?
    
    private var managementView = UIView()
    private var incrementButton = UIButton()
    private var daysLabel = UILabel()
    private var cellDate = Date()
    
    private var cellTracker = Tracker(eventTitle: "", emoji: "", color: .gray)
    
    override func prepareForReuse() {
        daysLabel.text = ""
        daysLabel.removeFromSuperview()
        incrementButton.removeFromSuperview()
        managementView.removeFromSuperview()
    }
    
    //MARK: - Status for select date
    
    private func checkIfRecorded() {
        allRecords = StorageService.shared.getRecords(for: cellTracker.id)

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
        
        pinImage.isHidden = !cellTracker.isPinned
        
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
        emojiLabel.backgroundColor = .AppColors.background
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
        titleLabel.textColor = .AppColors.white
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
        
        if viewWithTag(1) == nil {
            incrementButton.tag = 1
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
            incrementButton.tintColor = .AppColors.white
            incrementButton.clipsToBounds = true
            incrementButton.layer.cornerRadius = 17
            incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
            incrementButton.showsTouchWhenHighlighted = true
        }
        
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
        let daysCount = StorageService.shared.getRecords(for: cellTracker.id)
        daysLabel.text = dayFormatter.string(from: DateComponents(day: daysCount.count))
    }
    
    @objc func incrementButtonTapped() {
        let record = TrackerRecord(trackerID: cellTracker.id, date: StorageService.shared.calendar.startOfDay(for: cellDate))
        delegate?.updateRecords(with: record) { [weak self] newRecStatus in
            self?.isRecorded = newRecStatus
        }
        updateDay()
    }
}

