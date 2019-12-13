//
//  MessageViewController.swift
//  Messenger
//
//  Created by Suspect on 04.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

class MessageViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var sendMessageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var fetchedResultsController: NSFetchedResultsController<Message>!
    static var friend: Friend!


    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        setFetchedResultController()
        fetchedResultsController.delegate = self

        tableView.separatorStyle = .none
        sendMessageTextField.delegate = self
        self.title = MessageViewController.friend.login ?? ""

        scrollToBottom()
    }

    //MARK: Button Actions
    @IBAction func sendButtonTyped(_ sender: Any) {
        if sendMessageTextField.text == "" {
            CustomAnimations.shakeTextField(sendMessageTextField)
        } else {
            DummyMessengerAPI.sendMessage(sendMessageTextField.text ?? "", in: self)
            sendMessageTextField.text = ""

            DummyMessengerAPI.fetchDialogsData(in: self, completion: nil)

            scrollToBottom()
        }
    }


    //MARK: NotificationCenter Actions
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            animateViewMoving(keyboardFrame, up: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            animateViewMoving(keyboardFrame, up: false)
        }
    }

    func animateViewMoving (_ keyboardFrame: NSValue, up: Bool) {
        let moveValue = keyboardFrame.cgRectValue.height - 70
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        }, completion: nil)
    }

    //MARK: Private Methods
    private func setFetchedResultController() {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = NSPredicate(format: "friend.login = %@", MessageViewController.friend.login ?? "")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
    }

    private func scrollToBottom() {
        let messageCnt = fetchedResultsController.fetchedObjects!.count
        if messageCnt > 0 {
            self.tableView.scrollToRow(at: NSIndexPath.init(row: messageCnt - 1, section: 0) as IndexPath, at: .bottom, animated: false)
        }
    }

}

//MARK: UITextFieldDelegate
extension MessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


//MARK: UITableViewDelegate, UITableViewDataSource
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        as? MessageTableViewCell else {
            fatalError("The dequeued cell is not an instance of MessageTableViewCell.")
        }

        let message = fetchedResultsController.object(at: indexPath)

        cell.messageLabel.text = message.body ?? ""
        cell.messageView.backgroundColor = (message.senderId == MessageViewController.friend.id) ? .systemGray6 : .systemTeal

        cell.selectionStyle = .none

        return cell
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension MessageViewController: NSFetchedResultsControllerDelegate {
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
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        default:
            break
        }
    }
}

