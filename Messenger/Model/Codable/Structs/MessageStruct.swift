//
//  MessageStruct.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

struct MessageStruct: Codable {
    var body: String?
    var date: Date?
    var senderId: Int32
    
    private enum CodingKeys: String, CodingKey {
        case body
        case date = "CreatedAt"
        case senderId = "sender_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        body = try container.decode(String.self, forKey: .body)
        date = Utils.getDate(from: try container.decode(String.self, forKey: .date))
        senderId = try container.decode(Int32.self, forKey: .senderId)
    }
    
    init(senderId: Int32, body: String = "") {
        self.senderId = senderId
        self.body = body
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(body, forKey: .body)
        try container.encode(date, forKey: .date)
        try container.encode(senderId, forKey: .senderId)
    }
}
