//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 05.09.2023.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    var firstScreenVC: UIViewController? = nil
    
    private lazy var pages: [OnboardingPageController] = {
        let page1 = {
            let page1vc = OnboardingPageController()
            page1vc.setImage(UIImage(named: "Onboarding1"))
            page1vc.setTitle("Отслеживайте только то, что хотите")
            return page1vc
        }()
        
        let page2 = {
            let page2vc = OnboardingPageController()
            page2vc.setImage(UIImage(named: "Onboarding2"))
            page2vc.setTitle("Даже если это не литры воды и йога")
            return page2vc
        }()
        
        return [page1, page2]
    }()
    
    //MARK: - UI elements
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .AppColors.black
        pageControl.pageIndicatorTintColor = .AppColors.black.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var okButton: GenericAppButton = {
        let button = GenericAppButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
        setupViews()
    }
    
    //MARK: - UI setup
    
    private func setupViews() {
        view.addSubview(okButton)
        NSLayoutConstraint.activate([
            okButton.heightAnchor.constraint(equalToConstant: 60),
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    //MARK: - Navigation
    
    @objc private func okButtonTapped() {
        if firstScreenVC != nil {
            goToFirstScreen()
        }
    }
    
    func goToFirstScreen() {
        guard let firstScreenVC,
              let window = UIApplication.shared.windows.first else {
            fatalError("Invalid window config")
        }
        
        window.rootViewController = firstScreenVC
        window.makeKeyAndVisible()
        
        UIView.transition(with: window,
                          duration: 0.1,
                          options: [.transitionCrossDissolve,
                                    .overrideInheritedOptions,
                                    .curveEaseIn],
                          animations: nil)
    }
}

//MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first as? OnboardingPageController,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

//MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let onboardingViewController = viewController as? OnboardingPageController,
              let viewControllerIndex = pages.firstIndex(of: onboardingViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let onboardingViewController = viewController as? OnboardingPageController,
              let viewControllerIndex = pages.firstIndex(of: onboardingViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
}
