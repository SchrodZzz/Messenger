//
//  SignUpViewController.swift
//  Messenger
//
//  Created by Suspect on 08.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!


    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loginTextField.delegate = self
        passwordTextField.delegate = self
        passwordAgainTextField.delegate = self
    }

    //MARK: Button Actions
    @IBAction func signUpButtonTyped(_ sender: Any) {
        if let unfilledTextField = Utils.getFirstUnfilledTextField(from: [loginTextField, passwordTextField, passwordAgainTextField]) {
            CustomAnimations.shakeTextField(unfilledTextField)
        } else if passwordTextField.text ?? "" != passwordAgainTextField.text ?? "" {
            Alert.performAlert(to: self, message: "Passwords are not equal")
        } else {
            DummyMessengerAPI.signUpUser(in: self, login: loginTextField.text ?? "", password: passwordTextField.text ?? "", preparation: {
                self.indicator.startAnimating()
            }, completion: {
                self.indicator.stopAnimating()
            })
        }
    }

}

//MARK: UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
            return true
        } else if textField == passwordTextField {
            passwordAgainTextField.becomeFirstResponder()
            return true
        }
        return false
    }
}
