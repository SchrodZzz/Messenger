//
//  Message+CoreDataProperties.swift
//  Messenger
//
//  Created by Suspect on 12.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var body: String?
    @NSManaged public var date: Date?
    @NSManaged public var senderId: Int32
    @NSManaged public var friend: Friend?

}
