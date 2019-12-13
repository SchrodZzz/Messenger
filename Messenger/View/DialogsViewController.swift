//
//  DialogsViewController.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

class DialogsViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Friend>!

    private let refreshControl = UIRefreshControl()


    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setFetchedResultController()
        fetchedResultsController.delegate = self

        setupRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DummyMessengerAPI.fetchFriendsData(in: self, completion: {
            DummyMessengerAPI.fetchDialogsData(in: self, completion: {
                self.tableView.reloadData()
            })
        })
    }


    //MARK: Private Methods
    @objc private func refreshDialogsData(_ sender: Any) {
        DummyMessengerAPI.fetchDialogsData(in: self, completion: {
            self.refreshControl.endRefreshing()
        })
    }

    private func setupRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Dialogs Data ...")
        refreshControl.addTarget(self, action: #selector(refreshDialogsData), for: .valueChanged)
    }

    private func setFetchedResultController() {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
        request.predicate = NSPredicate(format: "user.login = %@ and messages.@count > 0", DummyMessengerAPI.userLogin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension DialogsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DialogCell", for: indexPath)
        as? DialogsTableViewCell else {
            fatalError("The dequeued cell is not an instance of DialogsTableViewCell.")
        }

        let friend = fetchedResultsController.object(at: indexPath)

        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "friend.login = %@", friend.login ?? "")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let messages = try! stack.context.fetch(request)

        if messages.count > 0 {
            let lastMessage = messages[0]
            cell.lastMessageLabel.text = (lastMessage.friend!.id == lastMessage.senderId
                ? lastMessage.friend!.login!
                : DummyMessengerAPI.userLogin)
                + ": " + lastMessage.body!
        } else {
            cell.lastMessageLabel.text = ""
        }

        cell.friendAvatar.image = UIImage(named: "defaultAvatar")
        cell.friendLoginLabel.text = friend.login ?? ""

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MessageViewController.friend = fetchedResultsController.object(at: indexPath)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rowsNum = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return rowsNum == 0 ? "You don't have dialogs" : ""
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension DialogsViewController: NSFetchedResultsControllerDelegate {
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
