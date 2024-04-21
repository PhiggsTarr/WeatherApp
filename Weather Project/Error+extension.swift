//
//  Error+extension.swift
//  Weather Project
//
//  Created by Kevin Tarr on 4/21/24.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = "Error", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}
