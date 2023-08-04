//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

final class CategoryListViewController: UIViewController {
    
    private var categories: [String] = []
    
    let addButton = GenericAppButton(type: .system)
    var placeholder = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Категория"
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func checkIfEmpty() {
        placeholder.isHidden = !categories.isEmpty
    }
    
    func setupUI() {
        placeholder = EmptyTablePlaceholder(type: .category, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.addTarget(self, action: #selector(newCategory), for: .touchUpInside)

        checkIfEmpty()
    }
    
    @objc func newCategory() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        show(UINavigationController(rootViewController: newCategoryVC), sender: nil)
    }
}

extension CategoryListViewController: NewCategoryDelegate {
    
    func addCategory(_ categoryName: String) {
        categories.append(categoryName)
        checkIfEmpty()
    }
}

#Preview {
    return UINavigationController(rootViewController: CategoryListViewController())
}
