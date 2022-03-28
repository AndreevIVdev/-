//
//  UIIVewController + Ext.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 27.03.2022.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController: UIAlertController = .init(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let action: UIAlertAction = .init(title: "Ok", style: UIAlertAction.Style.default) { _ in
            completion?()
        }
        alertController.addAction(action)
        alertController.view.tintColor = .label
        present(alertController, animated: true)
    }
}
