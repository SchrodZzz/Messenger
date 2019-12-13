//
//  Alert.swift
//  Messenger
//
//  Created by Suspect on 11.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class Alert {

    static func performAlertTo(_ viewController: UIViewController, with title: String = "Ooops...", message: String, shouldPopToRootVC: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var okAction: UIAlertAction
        if shouldPopToRootVC {
            okAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                viewController.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            okAction = UIAlertAction(title: "OK", style: .cancel)
        }
        alert.addAction(okAction)

        viewController.present(alert, animated: true)
    }
    
}


