//
//  FriendStruct.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

struct FriendStruct: Codable {
    var id: Int32
    var login: String

    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case login
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int32.self, forKey: .id)
        login = try container.decode(String.self, forKey: .login)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(login, forKey: .login)
    }
}
