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
        return table
    }()

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
    
    func checkVisibility() {
        statisticsTable.isHidden = (StorageService.shared.trackerCount < 1)
        print(StorageService.shared.trackerCount)
    }
    
    func setupUI() {
        statisticsTable.dataSource = self
        statisticsTable.delegate = self
        
        view.addSubview(statisticsTable)
        
        statisticsTable.translatesAutoresizingMaskIntoConstraints = false
  
        let search = UISearchController()
        search.hidesNavigationBarDuringPresentation = false
//        navigationItem.searchController = search
        search.searchBar.isUserInteractionEnabled = false
        search.searchBar.alpha = 1
        navigationItem.hidesSearchBarWhenScrolling = false
        
        statisticsTable.separatorStyle = .none
        statisticsTable.backgroundColor = .AppColors.white
        statisticsTable.isScrollEnabled = true
        statisticsTable.register(StatisticsCell.self, forCellReuseIdentifier: "statistics_cell")
        
        let layoutFrame = view.safeAreaLayoutGuide.layoutFrame
        let navBarFrame = search.searchBar.frame// ?? layoutFrame

        let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let navBarBottomY = navBarHeight + statusBarHeight
        
        let yo = {
//            guard let titleLabel = navigationItem.titleView as? UILabel else { return 0.0 }
            
            let className = "LargeTitle"
            for subview in navigationController!.navigationBar.subviews {
                // Get the name of the class as a string
                let elementName = String(describing: type(of: subview))
                // Check if the name contains the class name

                if elementName.contains(className) {
                    print("\(subview) is a \(className)")
                } else {
                    print("\(subview) is NOT a \(className)")
                    for subsubview in subview.subviews {
                        let elementName1 = String(describing: type(of: subsubview))
                        if elementName1.contains(className) {
                            print("\(subsubview) is a \(className)")
                        } else {
                            print("\(subsubview) is NOT a \(className)")
                        }
                    }
                }
            }
            
            var titleLabel = UIVisualEffectView()
            
            for subview in navigationController!.navigationBar.subviews {
                if let subview = subview as? UIVisualEffectView {
                    titleLabel = subview
                } else {
                    for subsubview in subview.subviews {

                        if let subsubview = subsubview as? UIVisualEffectView{
                            titleLabel = subsubview
                            print(subsubview)
                            break
                        }
                    }
                }
            }
            // Get the frame of the UILabel in the window's coordinate system
            let titleLabelFrame = titleLabel.convert(titleLabel.bounds, to: nil)
            // Get the max Y of the frame
            let titleLabelMaxY = titleLabelFrame.maxY
            
            return titleLabel.bounds.height
        }()
        
        print(yo)
        
        statisticsTable.frame = layoutFrame
        let navBottomInset = navigationController?.navigationBar.safeAreaInsets.bottom ?? 0
        print("INSET")
        print(navBottomInset)
        statisticsTable.contentInset = UIEdgeInsets(top: (navigationController?.navigationBar.frame.height ?? 0) + statusBarHeight + 53 - navBottomInset, left: 0, bottom: 0, right: 0)
        statisticsTable.isScrollEnabled = false
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "statistics_cell") as? StatisticsCell else {
            return UITableViewCell()
        }
        cell.setupCell()
        
        switch indexPath.row {
        case 0:
            cell.setDays(viewModel.statistics.bestDayTrackerCount)
            cell.setDescription("Лучший период")
        case 1:
            cell.setDays(viewModel.statistics.idealDaysCount)
            cell.setDescription("Идеальные дни")
        case 2:
            cell.setDays(viewModel.statistics.completedTrackerCount)
            cell.setDescription("Трекеров завершено")
        case 3:
            cell.setDays(viewModel.statistics.averageTrackerCount)
            cell.setDescription("Среднее значение")
        default:
            cell.setDays(0)
            cell.setDescription("👾")
        }
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}
