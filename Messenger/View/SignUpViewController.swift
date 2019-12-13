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

        indicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        passwordAgainTextField.isSecureTextEntry = true
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
        passwordAgainTextField.delegate = self
    }

    //MARK: Button Actions
    @IBAction func signUpButtonTyped(_ sender: Any) {
        if let unfilledTextField = getFirstUnfilledTextField() {
            CustomAnimations.shakeTextField(unfilledTextField)
        } else if passwordTextField.text ?? "" != passwordAgainTextField.text ?? "" {
            Alert.performAlertTo(self, message: "Passwords are not equal")
        } else {
            signUpUser(login: loginTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }

    //MARK: Private Methods
    private func signUpUser(login: String, password: String) {
        let json: [String: Any] = ["login": login, "password": password]
        let jsonBody = try? JSONSerialization.data(withJSONObject: json)

        let request = DummyMessengerAPI.createRequest(subPath: "/user/new", httpMethod: "POST", httpBody: jsonBody)

        indicator.startAnimating()

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                let responseJSON = try? JSONSerialization.jsonObject(with: data)
                if let responseJSON = responseJSON as? [String: Any] {
                    if responseJSON["status"] as! Int == 1 {
                        Alert.performAlertTo(self, with: "Successful", message: responseJSON["message"] as! String, shouldPopToRootVC: true)
                    } else {
                        Alert.performAlertTo(self, message: responseJSON["message"] as! String)
                    }
                } else {
                    Alert.performAlertTo(self, message: "Connection Error")
                }
            }
        }

        task.resume()
    }

    private func getFirstUnfilledTextField() -> UITextField? {
        if loginTextField.text == "" {
            return loginTextField
        } else if passwordTextField.text == "" {
            return passwordTextField
        } else if passwordAgainTextField.text == "" {
            return passwordAgainTextField
        } else {
            return nil
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
