//
//  Ex+UIViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import Foundation


import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, okAction: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            okAction?()
        }
        alertController.addAction(okButton)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
