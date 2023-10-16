//
//  AlertPresenter.swift
//  Tracker
//
//  Created by Aleksey Yakushev on 16.09.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(alert: UIAlertController)
}

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? { get }
    func presentAlert(alert: UIAlertController)
    func presentDeleteAlert(message: String, completion: @escaping () -> Void)
}

final class AlertPresenter: AlertPresenterProtocol {
    weak private(set) var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func presentAlert(alert: UIAlertController) {
        delegate?.show(alert: alert)
    }
    
    func presentDeleteAlert(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: message,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            completion()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        delegate?.show(alert: alert)
    }
}
