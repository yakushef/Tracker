//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

class TrackerTypeChoiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        navigationItem.title = "Создание трекера"
    }
    
    func setup(button: UIButton) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.tintColor = .appColors.white
        button.backgroundColor = .appColors.black
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
    }
    
    func setupUI() {
        let habitButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(addHabit))
        habitButton.setTitle("Привычка", for: .normal)
        setup(button: habitButton)
        
        let singleButton = UIButton.systemButton(with: UIImage(), target: self, action: #selector(addSingleEvent))
        singleButton.setTitle("Нерегулярное событие", for: .normal)
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
    
    @objc func addHabit() {
        let habitVC = NewTrackerViewController()
        habitVC.trackerType = .habit
        self.show(UINavigationController(rootViewController: habitVC), sender: nil)
    }
    
    @objc func addSingleEvent() {
        let eventVC = NewTrackerViewController()
        eventVC.trackerType = .singleEvent
        self.show(UINavigationController(rootViewController: eventVC), sender: nil)
    }
}

#Preview {
    return UINavigationController(rootViewController: TrackerTypeChoiceViewController())
}
