//
//  DummyMessengerAPI.swift
//  Messenger
//
//  Created by Suspect on 07.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DummyMessengerAPI {

    private static let path = "https://dummy-messenger-api.herokuapp.com/api"

    static var userLogin = ""
    static var userToken = ""

    static func createRequest(subPath: String, httpMethod: String, httpBody: Data?) -> URLRequest {
        guard let url = URL(string: self.path + subPath) else {
            fatalError("Can't create non nil url")
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = httpMethod
        request.httpBody = httpBody

        return request
    }

    static func createSession() -> URLSession {
        let sessionConfiguration: URLSessionConfiguration

        sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForResource = 60
        sessionConfiguration.timeoutIntervalForResource = 120
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let session = URLSession(configuration: sessionConfiguration)

        return session
    }
    
    static func fetchFriendsData(in vc: UIViewController, completion: (()->())?) {
        var request = DummyMessengerAPI.createRequest(subPath: "/me/friends/get/all", httpMethod: "GET", httpBody: nil)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")


        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                let responseJSON = try? JSONSerialization.jsonObject(with: data)
                if let responseJSON = responseJSON as? [String: Any] {
                    if responseJSON["status"] as! Int == 1 {
                        let friends = responseJSON["friends"] as! Array<Dictionary<String, Any>>
                        let sortedFriends = JSONParser.getSortedFriendsList(from: friends)
                        self.updateCoreData(sortedFriends)
                    } else {
                        Alert.performAlertTo(vc, message: responseJSON["message"] as! String)
                    }
                } else {
                    Alert.performAlertTo(vc, message: "Connection Error")
                }
                
                completion?()
            }
        }

        task.resume()
    }

    static func updateCoreData(_ friends: [FriendStruct]) {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let coreDataFriends = try! stack.context.fetch(request)

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login = %@", DummyMessengerAPI.userLogin)
        let users = try! stack.context.fetch(fetchRequest)
        let user = users[0]

        var idx = 0
        let friendEntity = NSEntityDescription.entity(forEntityName: "Friend", in: stack.context)!
        for curFriend in friends {
            let id = curFriend.id
            while idx < coreDataFriends.count && coreDataFriends[idx].id < id {
                idx += 1
            }

            if idx >= coreDataFriends.count || coreDataFriends[idx].id != id {
                let friend = Friend(entity: friendEntity, insertInto: stack.context)
                friend.id = id
                friend.login = curFriend.login
                user.addToFriends(friend)
            }
        }
        try! stack.context.save()
    }
    
    static func fetchDialogsData(in vc: UIViewController, completion: (()->())?) {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let friends = try! stack.context.fetch(request)
        
        for curFriend in friends {
            updateMessagesFor(curFriend, in: vc, completion: completion)
        }
    }

    static func updateMessagesFor(_ friend: Friend, in vc: UIViewController, completion: (()->())?) {
        let json: [String: Any] = ["receiver_id": friend.id]
        let jsonBody = try? JSONSerialization.data(withJSONObject: json)

        var request = DummyMessengerAPI.createRequest(subPath: "/me/messages/get/all", httpMethod: "POST", httpBody: jsonBody)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                let responseJSON = try? JSONSerialization.jsonObject(with: data)
                if let responseJSON = responseJSON as? [String: Any] {
                    if responseJSON["status"] as! Int == 1 {
                        let msgs = responseJSON["messages"] as! Array<Dictionary<String, Any>>
                        if msgs.count > 0 {
                            let messagesFromServer = JSONParser.getMessagesList(from: msgs)
                            let request: NSFetchRequest<Message> = Message.fetchRequest()
                            request.predicate = NSPredicate(format: "friend.login = %@", friend.login!)
                            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
                            let messagesFromCoreData = try! stack.context.fetch(request)

                            //at this app version I store all the messages in core data
                            if messagesFromCoreData.count < messagesFromServer.count {
                                var idx = messagesFromServer.count - 1
                                let lastMessageIndex = messagesFromCoreData.count - 1
                                let messageEntity = NSEntityDescription.entity(forEntityName: "Message", in: stack.context)!
                                if messagesFromCoreData.count != 0 {
                                    while messagesFromCoreData[lastMessageIndex].date! != messagesFromServer[idx].date
                                        || messagesFromCoreData[lastMessageIndex].body! != messagesFromServer[idx].body {
                                            idx -= 1
                                    }
                                } else {
                                    idx = 0
                                }
                                for i in idx+1 ..< messagesFromServer.count {
                                    let message = Message(entity: messageEntity, insertInto: stack.context)
                                    message.body = messagesFromServer[i].body
                                    message.senderId = messagesFromServer[i].senderId
                                    message.date = messagesFromServer[i].date
                                    friend.addToMessages(message)
                                }
                                try! stack.context.save()
                            }
                        }
                    } else {
                        Alert.performAlertTo(vc, message: responseJSON["message"] as! String)
                    }
                } else {
                    Alert.performAlertTo(vc, message: "Connection Error")
                }
                
                completion?()
            }
        }

        task.resume()
    }
    
    static func sendMessage(_ text: String, to: Int32 = MessageViewController.friend.id, in vc: UIViewController, completion: (()->())?) {
        let json: [String: Any] = ["receiver_id": to, "body": text]
        let jsonBody = try? JSONSerialization.data(withJSONObject: json)

        var request = DummyMessengerAPI.createRequest(subPath: "/me/messages/send", httpMethod: "POST", httpBody: jsonBody)
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
                         Alert.performAlertTo(vc, message: responseJSON["message"] as! String)
                    }
                } else {
                    Alert.performAlertTo(vc, message: "Connection Error")
                }
                
                completion?()
            }
        }

        task.resume()
    }

}
