//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class TrackerTypeChoiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        let newTrackerNavTitle = NSLocalizedString("newTracker.pageTitle", comment: "Создание трекера")
        navigationItem.title = newTrackerNavTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
    }
    
    private func setup(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.tintColor = .AppColors.white
        button.backgroundColor = .AppColors.black
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
    }
    
    private func setupUI() {
        let habitButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(addHabit))
        let habitButtonTitle = NSLocalizedString("newTracker.habit", comment: "Привычка")
        habitButton.setTitle(habitButtonTitle, for: .normal)
        setup(button: habitButton)
        
        let singleButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(addSingleEvent))
        let eventButtonTitle = NSLocalizedString("newTracker.event", comment: "Нерегулярное событие")
        singleButton.setTitle(eventButtonTitle, for: .normal)
        setup(button: singleButton)
        
        let buttonsStack = UIStackView()
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .vertical
        buttonsStack.alignment = .fill
        buttonsStack.spacing = 16

        
        buttonsStack.addArrangedSubview(habitButton)
        buttonsStack.addArrangedSubview(singleButton)
        view.addSubview(buttonsStack)
        
        buttonsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
    }
    
    @objc private func addHabit() {
        let habitVC = NewTrackerViewController()
        habitVC.trackerType = .habit
        NewTrackerDelegate.shared.setTrackerType(to: .habit)
        self.show(UINavigationController(rootViewController: habitVC), sender: nil)
    }
    
    @objc private func addSingleEvent() {
        let eventVC = NewTrackerViewController()
        eventVC.trackerType = .singleEvent
        NewTrackerDelegate.shared.setTrackerType(to: .singleEvent)
        self.show(UINavigationController(rootViewController: eventVC), sender: nil)
    }
}

