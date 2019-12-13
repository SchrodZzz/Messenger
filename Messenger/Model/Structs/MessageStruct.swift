//
//  MessageStruct.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

struct MessageStruct {
    var body: String
    var date: Date
    var senderId: Int32
    
    init(body: String, date: Date, senderId: Int32) {
        self.body = body
        self.date = date
        self.senderId = senderId
    }
}
