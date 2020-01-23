//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Suspect on 23.01.2020.
//  Copyright © 2020 Andrey Ivshin. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLogin: UILabel!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var settingsTable: UITableView!
    

    //MARK: Application life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCurrentUserData()

        Alert.performAlert(to: self, with: "Still in develop", message: "Sorry, but this screen is not finished yet, from here you can only logout from your current account")
    }
    
    //MARK: Private Methods
    private func showCurrentUserData() {
        userAvatar.image = DummyMessengerAPI.getPhotoForUser(with: DummyMessengerAPI.userID)
        userLogin.text = DummyMessengerAPI.userLogin
        userID.text = String(DummyMessengerAPI.userID)
    }
    
    //MARK: Button Actions
    @IBAction func logoutButtonTyped(_ sender: Any) {
        DummyMessengerAPI.logoutCurrentUser(in: self)
    }
    

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! SettingsTableViewCell

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }
}
