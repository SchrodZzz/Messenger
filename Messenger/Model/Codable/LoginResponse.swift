//
//  LoginResponse.swift
//  Messenger
//
//  Created by Suspect on 22.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation

class LoginResponse: ResponsePattern {
    var token: String?
    var tokenExpirationDateString: Date?

    private enum CodingKeys: String, CodingKey {
        case token
        case tokenExpirationDateString = "tokenExpDate"
    }

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decode(String.self, forKey: .token)
        tokenExpirationDateString = Utils.getDate(from: try container.decode(String.self, forKey: .tokenExpirationDateString))
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
        try container.encode(tokenExpirationDateString, forKey: .tokenExpirationDateString)
    }
}
