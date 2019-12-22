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

    }

    //MARK: Button Actions
    @IBAction func addFriendButtonTyped(_ sender: Any) {
        if idTextField.text == "" {
            CustomAnimations.shakeTextField(idTextField)
        } else {
            let id = Int32(idTextField.text ?? "") ?? -1
            idTextField.text = ""

            DummyMessengerAPI.addFriend(with: id, in: self, preparation: {
                self.indicator.startAnimating()
            }, completion: {
                self.indicator.stopAnimating()
            })
        }
    }

}
