//
//  JSONParser.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

class JSONParser {
    
    static func getSortedFriendsList(from raw: [[String:Any]]) -> [FriendStruct] {
        var friends: [FriendStruct] = []
        for curData in raw {
            let friendId = curData["ID"] as! Int32
            let friendLogin = curData["login"] as! String
            friends.append(FriendStruct(id: friendId, login: friendLogin))
        }
        
        friends.sort(by: { (lhs: FriendStruct, rhs: FriendStruct) -> Bool in
            return lhs.id < rhs.id
        })
        
        return friends
    }
    
    static func getMessagesList(from raw: [[String:Any]]) -> [MessageStruct] {
        var messages: [MessageStruct] = []
        for curData in raw {
            let body = curData["body"] as! String
            let senderId = curData["sender_id"] as! Int32
            let date = Utils.getDate(from: curData["CreatedAt"] as! String)
            messages.append(MessageStruct(body: body, date: date, senderId: senderId))
        }
        
        return messages
    }
}
