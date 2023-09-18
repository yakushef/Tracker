//
//  FilterViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 06.08.2023.
//

import UIKit

enum Filter: CaseIterable {
    case all
    case today
    case done
    case toDo
}

protocol FilterDelegate: AnyObject {
    func filterDidChange(to filter: Filter)
}

final class FilterViewController: UIViewController {
    
    private let filterTable = UITableView()
    private let filterList = Filter.allCases
    
    var appliedFilter: Filter = .all
    weak var delegate: FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .AppColors.white
        navigationItem.title = NSLocalizedString("filters",
                                                 comment: "Заголовок страницы фильтров")
        setupUI()
    }
    
    private func setupUI() {
        setupTable()
    }
    
    private func setupTable() {
        filterTable.delegate = self
        filterTable.dataSource = self
        filterTable.isScrollEnabled = false
        filterTable.register(UITableViewCell.self, forCellReuseIdentifier: "filter")
        view.addSubview(filterTable)
        filterTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filterTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            filterTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTable.heightAnchor.constraint(equalToConstant: CGFloat(75 * filterList.count))
        ])
        filterTable.backgroundColor = .clear
        filterTable.clipsToBounds = true
        filterTable.layer.cornerRadius = 16
        filterTable.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "filter") else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.tintColor = .AppColors.blue
        cell.backgroundColor = .AppColors.background
        cell.textLabel?.text = {
            switch filterList[indexPath.row] {
            case Filter.all:
                return NSLocalizedString("filter.all", comment: "все трекеры")
            case Filter.done:
                return NSLocalizedString("filter.done", comment: "завершенные")
            case Filter.today:
                return NSLocalizedString("filter.today", comment: "сегодня")
            case Filter.toDo:
                return NSLocalizedString("filter.toDo", comment: "незавершенные")
            }
        }()
        
        if filterList[indexPath.row] == appliedFilter {
            cell.accessoryType = .checkmark
        }
        
        if indexPath.row == 0 && filterList.count == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            switch indexPath.row {
            case 0:
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            case filterList.count - 1:
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            default:
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
        
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appliedFilter = filterList[indexPath.row]
        delegate?.filterDidChange(to: appliedFilter)
        tableView.reloadData()
        dismiss(animated: true)
    }
}
