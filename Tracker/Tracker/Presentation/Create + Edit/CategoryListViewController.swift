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
    let categoryTable = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Категория"
        view.backgroundColor = .systemBackground
        let categoryList = TrackerStorageService.shared.getAllCategories()
        categories = categoryList.map { $0.name }
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func checkIfEmpty() {
//        let categoryList = TrackerStorageService.shared.getAllCategories()
//        categories = categoryList.map { $0.name }
        placeholder.isHidden = !categories.isEmpty
        categoryTable.isHidden = categories.isEmpty
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
        
        setupTable()
        checkIfEmpty()
    }
    
    func setupTable() {
        categoryTable.delegate = self
        categoryTable.dataSource = self
        categoryTable.register(UITableViewCell.self, forCellReuseIdentifier: "category")
        view.addSubview(categoryTable)
        categoryTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryTable.leadingAnchor.constraint(equalTo: addButton.leadingAnchor),
            categoryTable.trailingAnchor.constraint(equalTo: addButton.trailingAnchor),
            categoryTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTable.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24)
        ])
    }
    
    @objc func newCategory() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        show(UINavigationController(rootViewController: newCategoryVC), sender: nil)
    }
}

extension CategoryListViewController: NewCategoryDelegate {
    
    func addCategory(_ categoryName: String) {
        TrackerStorageService.shared.addCategory(TrackerCategory(name: categoryName, trackers: []))
        categories.append(categoryName)
        checkIfEmpty()
        categoryTable.performBatchUpdates({
            categoryTable.insertRows(at: [IndexPath(row: (categories.count - 1), section: 0)], with: .automatic)
        })
    }
}

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
           }
        guard let presentingNavVC = presentingViewController as? UINavigationController,
        let presentingVC = presentingNavVC.viewControllers.first as? NewTrackerViewController else { return }
        
            presentingVC.category = categories[indexPath.row]
            dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.tintColor = .appColors.blue
        cell.backgroundColor = .appColors.lightGray
        cell.textLabel?.text = categories[indexPath.row]
        return cell
    }
}

#Preview {
    return UINavigationController(rootViewController: CategoryListViewController())
}
