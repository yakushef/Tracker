//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 04.08.2023.
//

import UIKit

final class CategoryListViewController: UIViewController {
    
    private var viewModel = CategoryListViewModel()
    
    private let addButton = GenericAppButton(type: .system)
    private var placeholder = UIView()
    private let categoryTable = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: StorageService.didUpdateCategories,
                                               object: nil,
                                               queue: .main,
                                               using: { [weak self] _ in
            self?.viewModel.updateCategories()
        })
        
        viewModel.$categoryNameList.makeBinding { [weak self] _ in
            self?.checkIfEmpty()
            self?.categoryTable.separatorStyle = .singleLine
            self?.categoryTable.reloadData()
        }
        
        let categotyTitle = NSLocalizedString("newTracker.category", comment: "Категория")
        navigationItem.title = categotyTitle
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        
        view.backgroundColor = .systemBackground
        categoryTable.isScrollEnabled = false
        setupUI()
    }
    
    private func checkIfEmpty() {
        placeholder.isHidden = !viewModel.categoryNameList.isEmpty
        categoryTable.isHidden = viewModel.categoryNameList.isEmpty
    }
    
    private func setupUI() {
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        let addCategoryButtonText = NSLocalizedString("buttons.addCategory", comment: "Добавить категорию")
        addButton.setTitle(addCategoryButtonText, for: .normal)
        addButton.addTarget(self, action: #selector(newCategory), for: .touchUpInside)
        
        placeholder = EmptyTablePlaceholder(type: .category, frame: view.safeAreaLayoutGuide.layoutFrame)
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placeholder.bottomAnchor.constraint(equalTo: addButton.topAnchor),
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholder.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupTable()
        checkIfEmpty()
    }
    
    private func setupTable() {
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
    
    @objc private func newCategory() {
        let newCategoryVC = NewCategoryViewController()
        show(UINavigationController(rootViewController: newCategoryVC), sender: nil)
    }
}

extension CategoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        NewTrackerDelegate.shared.setNewTrackerCategoryName(to: viewModel.categoryNameList[indexPath.row])
        dismiss(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if 75 * CGFloat(viewModel.categoryNameList.count) > categoryTable.frame.height {
            categoryTable.isScrollEnabled = true
        } else {
            categoryTable.isScrollEnabled = false
        }
        return 75
    }
}

extension CategoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoryNameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.tintColor = .AppColors.blue
        cell.backgroundColor = .AppColors.background
        cell.textLabel?.text = viewModel.categoryNameList[indexPath.row]
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 16
        cell.layoutSubviews()
        
        if indexPath.row == 0 && viewModel.categoryNameList.count == 1 {
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            switch indexPath.row {
            case 0:
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            case viewModel.categoryNameList.count - 1:
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            default:
                cell.layer.maskedCorners = []
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
        return cell
    }
}
