//
//  Response.swift
//  Messenger
//
//  Created by Suspect on 22.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

class ResponsePattern: Codable {
    var message: String?
    var statusIsOK: Bool?

    private enum CodingKeys: String, CodingKey {
        case message
        case statusIsOK = "status"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        statusIsOK = try container.decode(Bool.self, forKey: .statusIsOK)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
        try container.encode(statusIsOK, forKey: .statusIsOK)
    }
}
