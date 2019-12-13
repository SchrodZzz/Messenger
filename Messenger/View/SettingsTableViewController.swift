//
//  SettingsTableViewController.swift
//  Messenger
//
//  Created by Suspect on 04.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {

    //MARK: Properties
    @IBOutlet weak var logOutButton: UIBarButtonItem!


    //MARK: Application life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alert.performAlertTo(self, with: "Still in develop", message: "Sorry, but this View is not finished yet, from here you can only logout from your current account")


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Button Actions
    @IBAction func logOutButtonTyped(_ sender: Any) {
        logoutCurrentUser()
    }

    //MARK: Private Methods
    private func logoutCurrentUser() {
        var request = DummyMessengerAPI.createRequest(subPath: "/user/logout", httpMethod: "POST", httpBody: nil)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                let responseJSON = try? JSONSerialization.jsonObject(with: data)
                if let responseJSON = responseJSON as? [String: Any] {
                    if responseJSON["status"] as! Int == 0 {
                        Alert.performAlertTo(self, message: responseJSON["message"] as! String)
                    } else {
                        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Token")
                        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
                        let tokens = try! stack.context.fetch(request)
                        let token = tokens[0] as! NSManagedObject
                        token.setValue(Utils.getCurrentDate(), forKey: "expirationDate")
                        
                        try! stack.context.save()
                        
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    Alert.performAlertTo(self, message: "Connection Error")
                }
            }
        }

        task.resume()
    }


}