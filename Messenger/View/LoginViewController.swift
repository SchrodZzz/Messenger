//
//  LoginViewController.swift
//  Messenger
//
//  Created by Suspect on 06.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

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
        if let unfilledTextField = Utils.getFirstUnfilledTextField(from: [loginTextField, passwordTextField]) {
            CustomAnimations.shakeTextField(unfilledTextField)
        } else {
            DummyMessengerAPI.authUser(in: self, login: login, password: passwordTextField.text ?? "", preparation: {
                self.indicator.startAnimating()
            }, completion: {
                self.indicator.stopAnimating()
            })

            passwordTextField.text = ""
        }
    }

    @IBAction func signUpButtonTyped(_ sender: Any) {
        self.performSegue(withIdentifier: "toSighUpScreenSegue", sender: nil)
    }


    //MARK: Private Methods
    private func setFetchedResultController() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
        request.predicate = NSPredicate(format: "token.expirationDate > %@", Utils.getCurrentDate() as NSDate)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        guard let _ = try? fetchedResultsController.performFetch() else {
            Alert.performAlert(to: self, message: "Can't perform fetch from current context")
            return
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoggedUserCell", for: indexPath) as! LoggedUsersTableViewCell

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
        guard let tokens = try? stack.context.fetch(fetchRequest) else {
            Alert.performAlert(to: self, message: "Can't fetch from current context")
            return
        }
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

        guard let newIndexPath = newIndexPath else {
            Alert.performAlert(to: self, message: "FetchedResultsController can't update object")
            return
        }

        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath], with: .none)
        case .delete:
            tableView.deleteRows(at: [newIndexPath], with: .none)
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
