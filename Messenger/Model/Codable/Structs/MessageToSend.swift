//
//  MessageToSend.swift
//  Messenger
//
//  Created by Suspect on 22.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

struct MessageToSend: Codable {
    var receiverId: Int32
    var body: String

    init(receiverId: Int32, body: String = "") {
        self.receiverId = receiverId
        self.body = body
    }
}
