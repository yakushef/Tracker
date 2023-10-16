//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 01.08.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    let viewModel = StatisticsViewModel()
    
    var placeholder = UIView()
    
    lazy var statisticsTable = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .AppColors.white
        table.isScrollEnabled = false
        return table
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$statistics.makeBinding(action: { [weak self] _ in
            self?.checkVisibility()
            self?.statisticsTable.reloadData()
        })
        
        view.backgroundColor = .AppColors.white
        let statTitle = NSLocalizedString("statisticsPage.title",
                                          comment: "Заголовок экрана статистики")
        navigationItem.title = statTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        placeholder = EmptyTablePlaceholder(type: .statistics, frame: view.safeAreaLayoutGuide.layoutFrame)
        view.addSubview(placeholder)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateStatistics()
    }
    
    //MARK: - UI
    
    func checkVisibility() {
        statisticsTable.isHidden = (StorageService.shared.trackerCount < 1)
        print(StorageService.shared.trackerCount)
    }
    
    func setupUI() {
        statisticsTable.dataSource = self
        statisticsTable.delegate = self
        
        view.addSubview(statisticsTable)
        statisticsTable.translatesAutoresizingMaskIntoConstraints = false
    
        statisticsTable.register(StatisticsCell.self, forCellReuseIdentifier: "statistics_cell")
        
        let layoutFrame = view.safeAreaLayoutGuide.layoutFrame
        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let statusBarHeight = scene?.statusBarManager?.statusBarFrame.height ?? 0
        
        statisticsTable.frame = layoutFrame
        
        let navBottomInset = navigationController?.navigationBar.safeAreaInsets.bottom ?? 0
        
        statisticsTable.contentInset = UIEdgeInsets(top: navBarHeight + statusBarHeight + 53 - navBottomInset,
                                                    left: 0,
                                                    bottom: 0,
                                                    right: 0)
    }
}

// MARK: - TableView Data Source

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "statistics_cell") as? StatisticsCell else {
            return UITableViewCell()
        }
        cell.setupCell()
        
        switch indexPath.row {
        case 0:
            cell.setDays(viewModel.statistics.completedTrackerCount)
            cell.setDescription(NSLocalizedString("statistics.total", comment: "Трекеров завершено"))
        default:
            cell.setDays(0)
            cell.setDescription("👾")
        }
        return cell
    }
}

//MARK: - TableView Delegate

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}
