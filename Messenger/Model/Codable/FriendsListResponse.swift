//
//  GetFriendsListResponse.swift
//  Messenger
//
//  Created by Suspect on 22.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

class FriendsListResponse: ResponsePattern {
    var friends: [FriendStruct]?

    private enum CodingKeys: String, CodingKey {
        case friends
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        friends = try container.decode([FriendStruct].self, forKey: .friends)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(friends, forKey: .friends)
    }

    func sortFriends() {
        if var friends = friends {
            friends.sort(by: { (lhs: FriendStruct, rhs: FriendStruct) -> Bool in
                return lhs.id < rhs.id
            })
            self.friends = friends
        }
    }
}
