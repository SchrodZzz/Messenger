//
//  Utils.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import Foundation
import UIKit

class Utils {

    static func getCurrentDate() -> Date {
        return Date()
    }

    static func getDate(from string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from: string)
        return date
    }

    static func getFirstUnfilledTextField(from textFields: [UITextField]) -> UITextField? {
        return textFields.first(where: { $0.text == "" })
    }

}
