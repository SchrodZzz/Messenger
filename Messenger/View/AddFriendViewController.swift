//
//  FriendAddViewController.swift
//  Messenger
//
//  Created by Suspect on 04.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!


    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.hidesWhenStopped = true
    }

    //MARK: Button Actions
    @IBAction func addFriendButtonTyped(_ sender: Any) {
        if idTextField.text == "" {
            CustomAnimations.shakeTextField(idTextField)
        } else {
            let id = Int32(idTextField.text ?? "-1") ?? -1
            idTextField.text = ""
            
            addFriend(with: id)
        }
    }

    //MARK: Private Methods
    private func addFriend(with id: Int32) {
        let json: [String: Any] = ["own_id": id]
        let jsonBody = try? JSONSerialization.data(withJSONObject: json)

        var request = DummyMessengerAPI.createRequest(subPath: "/me/friends/add", httpMethod: "POST", httpBody: jsonBody)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

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
}
