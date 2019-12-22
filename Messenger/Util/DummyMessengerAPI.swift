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

#warning("TODO: Refactor once more time")
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


    //MARK: User
    static func authUser(in vc: UIViewController, login: String, password: String, preparation: (() -> ())?, completion: (() -> ())?) {
        guard let jsonBody = try? JSONEncoder().encode(UserStruct(login: login, password: password)) else {
            Alert.performAlert(to: vc, message: "Data Encode Error")
            return
        }

        let request = DummyMessengerAPI.createRequest(subPath: "/user/login", httpMethod: "POST", httpBody: jsonBody)

        preparation?()

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    guard let tokenEntity = NSEntityDescription.entity(forEntityName: "Token", in: stack.context) else {
                        Alert.performAlert(to: vc, message: "Can't create entity in current context")
                        return
                    }
                    let token = Token(entity: tokenEntity, insertInto: stack.context)
                    token.expirationDate = response.tokenExpirationDateString
                    token.value = response.token
                    guard let _ = try? stack.context.save() else {
                        Alert.performAlert(to: vc, message: "Can't save entity in current context")
                        return
                    }

                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "User")
                    fetchRequest.predicate = NSPredicate(format: "login = %@", login)
                    guard let users = try? stack.context.fetch(fetchRequest) else {
                        Alert.performAlert(to: vc, message: "Can't fetch from current context")
                        return
                    }

                    if users.count == 0 {
                        guard let userEntity = NSEntityDescription.entity(forEntityName: "User", in: stack.context) else {
                            Alert.performAlert(to: vc, message: "Can't create entity in current context")
                            return
                        }
                        let user = User(entity: userEntity, insertInto: stack.context)
                        user.login = login
                        user.token = token

                        guard let _ = try? stack.context.save() else {
                            Alert.performAlert(to: vc, message: "Can't save entity in current context")
                            return
                        }
                    } else {
                        if let user = users[0] as? NSManagedObject {
                            user.setValue(token, forKey: "token")
                        }
                    }

                    DummyMessengerAPI.userLogin = login
                    DummyMessengerAPI.userToken = token.value ?? ""
                    vc.performSegue(withIdentifier: "toMainControllerSegue", sender: nil)
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

    static func signUpUser(in vc: UIViewController, login: String, password: String, preparation: (() -> ())?, completion: (() -> ())?) {
        guard let jsonBody = try? JSONEncoder().encode(UserStruct(login: login, password: password)) else {
            Alert.performAlert(to: vc, message: "Data Encode Error")
            return
        }

        let request = DummyMessengerAPI.createRequest(subPath: "/user/new", httpMethod: "POST", httpBody: jsonBody)

        preparation?()

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(ResponsePattern.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    Alert.performAlert(to: vc, with: "Successful", message: response.message ?? "Unknown Error", shouldPopToRootVC: true)
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

    static func logoutCurrentUser(in vc: UIViewController) {
        var request = DummyMessengerAPI.createRequest(subPath: "/user/logout", httpMethod: "POST", httpBody: nil)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(ResponsePattern.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Token")
                    request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)

                    guard let tokens = try? stack.context.fetch(request) else {
                        Alert.performAlert(to: vc, message: "Can't fetch from current context")
                        return
                    }

                    if let token = tokens[0] as? NSManagedObject {
                        token.setValue(Utils.getCurrentDate(), forKey: "expirationDate")
                    }

                    guard let _ = try? stack.context.save() else {
                        Alert.performAlert(to: vc, message: "Can't save in current context")
                        return
                    }

                    vc.dismiss(animated: true, completion: nil)
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }
            }
        }

        task.resume()
    }


    //MARK: Friends
    static func addFriend(with id: Int32, in vc: UIViewController, preparation: (() -> ())?, completion: (() -> ())?) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let jsonBody = try? encoder.encode(FriendToAdd(ownId: id)) else {
            Alert.performAlert(to: vc, message: "Data Encode Error")
            return
        }

        var request = DummyMessengerAPI.createRequest(subPath: "/me/friends/add", httpMethod: "POST", httpBody: jsonBody)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        preparation?()

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(ResponsePattern.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    Alert.performAlert(to: vc, with: "Successful", message: response.message ?? "Unknown Error", shouldPopToRootVC: true)
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

    static func fetchFriendsData(in vc: UIViewController, completion: (() -> ())?) {
        var request = DummyMessengerAPI.createRequest(subPath: "/me/friends/get/all", httpMethod: "GET", httpBody: nil)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")


        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(FriendsListResponse.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    response.sortFriends()
                    if let sortedFriends = response.friends {
                        self.updateFriendsCoreData(sortedFriends, in: vc)
                    }
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

    static func updateFriendsCoreData(_ friends: [FriendStruct], in vc: UIViewController) {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        guard let coreDataFriends = try? stack.context.fetch(request) else {
            Alert.performAlert(to: vc, message: "Can't fetch from current context")
            return
        }

        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "login = %@", DummyMessengerAPI.userLogin)

        guard let users = try? stack.context.fetch(fetchRequest) else {
            Alert.performAlert(to: vc, message: "Can't fetch from current context")
            return
        }
        let user = users[0]

        var idx = 0
        guard let friendEntity = NSEntityDescription.entity(forEntityName: "Friend", in: stack.context) else {
            Alert.performAlert(to: vc, message: "Can't create entity in current context")
            return
        }
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

        guard let _ = try? stack.context.save() else {
            Alert.performAlert(to: vc, message: "Can't save current context")
            return
        }
    }


    //MARK: Messages
    static func fetchDialogsData(in vc: UIViewController, completion: (() -> ())?) {
        let request: NSFetchRequest<Friend> = Friend.fetchRequest()
        request.predicate = NSPredicate(format: "user.login = %@", DummyMessengerAPI.userLogin)
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        guard let friends = try? stack.context.fetch(request) else {
            Alert.performAlert(to: vc, message: "Can't fetch from current context")
            return
        }

        for curFriend in friends {
            updateMessagesFor(curFriend, in: vc, completion: completion)
        }
    }

    static func updateMessagesFor(_ friend: Friend, in vc: UIViewController, completion: (() -> ())?) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let jsonBody = try? encoder.encode(MessageToSend(receiverId: friend.id)) else {
            Alert.performAlert(to: vc, message: "Data Encode Error")
            return
        }

        var request = DummyMessengerAPI.createRequest(subPath: "/me/messages/get/all", httpMethod: "POST", httpBody: jsonBody)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(MessagesListResponse.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if response.statusIsOK ?? false {
                    let messagesFromServer = response.messages ?? []
                    if messagesFromServer.count > 0 {
                        let request: NSFetchRequest<Message> = Message.fetchRequest()
                        request.predicate = NSPredicate(format: "friend.login = %@", friend.login ?? "")
                        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

                        guard let messagesFromCoreData = try? stack.context.fetch(request) else {
                            Alert.performAlert(to: vc, message: "Can't fetch from current context")
                            return
                        }

                        if messagesFromCoreData.count < messagesFromServer.count {
                            var idx = messagesFromServer.count - 1
                            let lastMessageIndex = messagesFromCoreData.count - 1
                            guard let messageEntity = NSEntityDescription.entity(forEntityName: "Message", in: stack.context) else {
                                Alert.performAlert(to: vc, message: "Can't create entity in current context")
                                return
                            }
                            if messagesFromCoreData.count != 0 {
                                guard let lastCoreDataMessageDate = messagesFromCoreData[lastMessageIndex].date, let lastCoreDataMessageBody = messagesFromCoreData[lastMessageIndex].body else {
                                    Alert.performAlert(to: vc, message: "Unknown Core Data Error")
                                    return
                                }
                                while lastCoreDataMessageDate != messagesFromServer[idx].date
                                    || lastCoreDataMessageBody != messagesFromServer[idx].body {
                                        idx -= 1
                                }
                            } else {
                                idx = -1
                            }
                            for i in idx + 1 ..< messagesFromServer.count {
                                let message = Message(entity: messageEntity, insertInto: stack.context)
                                message.body = messagesFromServer[i].body
                                message.senderId = messagesFromServer[i].senderId
                                message.date = messagesFromServer[i].date
                                friend.addToMessages(message)
                            }
                            guard let _ = try? stack.context.save() else {
                                Alert.performAlert(to: vc, message: "Can't save current context")
                                return
                            }
                        }
                    }
                } else {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

    static func sendMessage(_ text: String, to: Int32 = MessageViewController.friend.id, in vc: UIViewController, completion: (() -> ())?) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        guard let jsonBody = try? encoder.encode(MessageToSend(receiverId: to, body: text)) else {
            Alert.performAlert(to: vc, message: "Data Encode Error")
            return
        }

        var request = DummyMessengerAPI.createRequest(subPath: "/me/messages/send", httpMethod: "POST", httpBody: jsonBody)
        request.addValue("Bearer " + DummyMessengerAPI.userToken, forHTTPHeaderField: "Authorization")

        let task = DummyMessengerAPI.createSession().dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                Alert.performAlert(to: vc, message: error?.localizedDescription ?? "No data")
                return
            }
            DispatchQueue.main.async {
                guard let response = try? JSONDecoder().decode(ResponsePattern.self, from: data) else {
                    Alert.performAlert(to: vc, message: "Connection Error")
                    return
                }

                if !(response.statusIsOK ?? false) {
                    Alert.performAlert(to: vc, message: response.message ?? "Data Decode Error")
                }

                completion?()
            }
        }

        task.resume()
    }

}
