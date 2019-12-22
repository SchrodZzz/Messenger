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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { _ in
            self.updateDialog()
        })

        setFetchedResultController()
        fetchedResultsController.delegate = self

        tableView.separatorStyle = .none
        sendMessageTextField.delegate = self
        self.title = MessageViewController.friend.login ?? ""
    }

    #warning("TODO: fix the scroll to bottom 'jump'")
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scrollToBottom()
    }

    //MARK: Button Actions
    @IBAction func sendButtonTyped(_ sender: Any) {
        if sendMessageTextField.text == "" {
            CustomAnimations.shakeTextField(sendMessageTextField)
        } else {
            DummyMessengerAPI.sendMessage(sendMessageTextField.text ?? "", in: self, completion: {
                self.updateDialog()
            })
            sendMessageTextField.text = ""
        }
    }


    //MARK: NotificationCenter Actions
    #warning("TODO: fix keyboardWillChange")
    @objc func keyboardWillChange(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let moveUp = -keyboardFrame.cgRectValue.height
            let moveDown = UIScreen.main.bounds.height - self.view.frame.maxY
            let up = self.view.frame.maxY == UIScreen.main.bounds.height
            let movement: CGFloat = (up ? moveUp : moveDown)
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
            }, completion: nil)
        }
    }

    //MARK: Private Methods
    private func setFetchedResultController() {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = NSPredicate(format: "friend.login = %@", MessageViewController.friend.login ?? "")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        guard let _ = try? fetchedResultsController.performFetch() else {
            Alert.performAlert(to: self, message: "Can't fetch from current context")
            return
        }
    }

    private func updateDialog() {
        DummyMessengerAPI.fetchDialogsData(in: self, completion: {
            self.tableView.reloadData()
            self.scrollToBottom(animated: true)
        })
    }

    private func scrollToBottom(animated: Bool = false) {
        let messagesCount = fetchedResultsController.fetchedObjects?.count ?? 0
        if messagesCount > 0 {
            self.tableView.scrollToRow(at: NSIndexPath.init(row: messagesCount - 1, section: 0) as IndexPath, at: .bottom, animated: animated)
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
        let message = fetchedResultsController.object(at: indexPath)
        let senderIsFriend = message.senderId == MessageViewController.friend.id

        let cell = tableView.dequeueReusableCell(withIdentifier: senderIsFriend ? "FriendMessageCell" : "UserMessageCell", for: indexPath) as! MessageTableViewCell

        cell.messageLabel.text = message.body ?? ""

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

        guard let newIndexPath = newIndexPath else {
            Alert.performAlert(to: self, message: "FetchedResultsController can't update object")
            return
        }

        if type == .insert {
            tableView.insertRows(at: [newIndexPath], with: .none)
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

        if type == .insert {
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .none)
        }
    }
}

