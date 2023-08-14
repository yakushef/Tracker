//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

protocol NewCategoryDelegate: AnyObject {
    func addCategory(_ categoryName: String)
}

final class NewCategoryViewController: UIViewController {
    
    let textField = TrackerNameField()
    private let doneButton = GenericAppButton(type: .system)
    
    weak var delegate: NewCategoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Новая категория"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(textField)
        textField.backgroundColor = .appColors.gray
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
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .appColors.background
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        doneButton.setTitle("Готово", for: .normal)
        doneButton.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneButton.switchActiveState(isActive: false)
    }
    
    func textChanged(to text: String) {
        doneButton.switchActiveState(isActive: !text.isEmpty)
    }
    
    @objc func done() {
        if let text = textField.text {
            delegate?.addCategory(text) }
        dismiss(animated: true)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textChanged(to: textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    return UINavigationController(rootViewController: NewCategoryViewController())
}
