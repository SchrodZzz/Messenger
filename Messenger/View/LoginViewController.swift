//
//  LoginViewController.swift
//  Messenger
//
//  Created by Suspect on 06.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

let stack = CoreDataStack()

class LoginViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIBarButtonItem!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!

    var fetchedResultsController: NSFetchedResultsController<User>!


    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setFetchedResultController()
        fetchedResultsController.delegate = self

        tableView.separatorStyle = .none
        indicator.hidesWhenStopped = true
        passwordTextField.isSecureTextEntry = true
        
        loginTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setFetchedResultController()
        tableView.reloadData()
    }

    //MARK: Button Actions
    @IBAction func loginButtonTyped(_ sender: Any) {
        let login = loginTextField.text ?? ""
        if let unfilledTextField = getFirstUnfilledTextField() {
            CustomAnimations.shakeTextField(unfilledTextField)
        } else {
            authUser(login: login, password: passwordTextField.text ?? "")

            passwordTextField.text = ""
        }
    }

    @IBAction func signUpButtonTyped(_ sender: Any) {
        self.performSegue(withIdentifier: "toSighUpScreenSegue", sender: nil)
    }


    //MARK: Private Methods
    private func getFirstUnfilledTextField() -> UITextField? {
        if loginTextField.text == "" {
            return loginTextField
        } else if passwordTextField.text == "" {
            return passwordTextField
        } else {
            return nil
        }
    }

    private func authUser(login: String, password: String) {
        let json: [String: Any] = ["login": login, "password": password]
        let jsonBody = try? JSONSerialization.data(withJSONObject: json)

        let request = DummyMessengerAPI.createRequest(subPath: "/user/login", httpMethod: "POST", httpBody: jsonBody)

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
                    if responseJSON["status"] as! Int == 0 {
                        Alert.performAlertTo(self, message: responseJSON["message"] as! String)
                    } else {
                        let tokenEntity = NSEntityDescription.entity(forEntityName: "Token", in: stack.context)!
                        let token = Token(entity: tokenEntity, insertInto: stack.context)
                        token.expirationDate = Utils.getDate(from: responseJSON["tokenExpDate"] as! String)
                        token.value = responseJSON["token"] as? String
                        try! stack.context.save()

                        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
                        fetchRequest.predicate = NSPredicate(format: "login = %@", login)
                        let users = try! stack.context.fetch(fetchRequest)

                        if users.count == 0 {
                            let userEntity = NSEntityDescription.entity(forEntityName: "User", in: stack.context)!
                            let user = User(entity: userEntity, insertInto: stack.context)
                            user.login = login
                            user.token = token
                            try! stack.context.save()
                        } else {
                            let user = users[0] as! NSManagedObject
                            user.setValue(token, forKey: "token")
                        }

                        DummyMessengerAPI.userLogin = login
                        DummyMessengerAPI.userToken = token.value ?? ""
                        self.performSegue(withIdentifier: "toMainControllerSegue", sender: nil)
                    }
                } else {
                    Alert.performAlertTo(self, message: "Connection Error")
                }
            }
        }

        task.resume()
    }

    private func setFetchedResultController() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
        request.predicate = NSPredicate(format: "token.expirationDate > %@", Utils.getCurrentDate() as NSDate)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
    }

}


//MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
            return true
        }
        return false
    }
}


//MARK: UITableViewDelegate, UITableViewDataSource
extension LoginViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoggedUserCell", for: indexPath)
        as? LoggedUsersTableViewCell else {
            fatalError("The dequeued cell is not an instance of LoggedUsersTableViewCell.")
        }

        let user = fetchedResultsController.object(at: indexPath)
        cell.avatarImageView.image = UIImage(named: "defaultAvatar")
        cell.loginLabel.text = user.login ?? ""

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = fetchedResultsController.object(at: indexPath)
        let login = user.login ?? ""

        let fetchRequest: NSFetchRequest<Token> = Token.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user.login = %@", login)
        let tokens = try! stack.context.fetch(fetchRequest)
        let token = tokens[0]

        DummyMessengerAPI.userLogin = login
        DummyMessengerAPI.userToken = token.value ?? ""
        self.performSegue(withIdentifier: "toMainControllerSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rowsNum = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return rowsNum > 0 ? "Authorized Users" : ""
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension LoginViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            tableView.deleteRows(at: [newIndexPath!], with: .none)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .none)
        default:
            break
        }
    }
}
