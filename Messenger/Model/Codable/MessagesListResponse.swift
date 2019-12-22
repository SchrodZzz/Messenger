//
//  MessagesList.swift
//  Messenger
//
//  Created by Suspect on 22.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

class MessagesListResponse: ResponsePattern {
    var messages: [MessageStruct]?

    private enum CodingKeys: String, CodingKey {
        case messages
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messages = try container.decode([MessageStruct].self, forKey: .messages)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messages, forKey: .messages)
    }
}
