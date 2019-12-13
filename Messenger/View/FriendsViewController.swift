//
//  FriendsViewController.swift
//  Messenger
//
//  Created by Suspect on 11.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import UIKit
import CoreData

class FriendsViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Friend>!

    private let refreshControl = UIRefreshControl()

    //MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none

        setFetchedResultController()
        fetchedResultsController.delegate = self

        setupRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DummyMessengerAPI.fetchFriendsData(in: self, completion: {
            self.tableView.reloadData()
        })
    }

    //MARK: Private Methods
    @objc private func refreshFriendsData(_ sender: Any) {
        DummyMessengerAPI.fetchFriendsData(in: self, completion: {
            self.refreshControl.endRefreshing()
        })
    }

    private func setupRefreshControl() {
        tableView.refreshControl = refreshControl
        refreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Friends Data ...")
        refreshControl.addTarget(self, action: #selector(refreshFriendsData), for: .valueChanged)
    }

    private func setFetchedResultController() {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "login", ascending: true)]
        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsController.performFetch()
    }

}


//MARK: UITableViewDelegate, UITableViewDataSource
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        as? FriendsTableViewCell else {
            fatalError("The dequeued cell is not an instance of FriendsTableViewCell.")
        }

        let friend = fetchedResultsController.object(at: indexPath)
        cell.avatarImageView.image = UIImage(named: "defaultAvatar")
        cell.loginLabel.text = friend.login ?? ""
        cell.idLabel.text = "ID: " + String(friend.id)

        cell.selectionStyle = .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = fetchedResultsController.object(at: indexPath)
        if friend.messages?.count == 0 {
            MessageViewController.friend = friend
            self.performSegue(withIdentifier: "toMessagesSegue", sender: nil)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let rowsNum = fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return rowsNum == 0 ? "You don't have friends" : ""
    }
}

//MARK: NSFetchedResultsControllerDelegate
extension FriendsViewController: NSFetchedResultsControllerDelegate {
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
