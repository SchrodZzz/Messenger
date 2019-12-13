//
//  Friend+CoreDataProperties.swift
//  Messenger
//
//  Created by Suspect on 08.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var avatar: String?
    @NSManaged public var id: Int32
    @NSManaged public var login: String?
    @NSManaged public var messages: NSSet?
    @NSManaged public var user: User?

}

// MARK: Generated accessors for messages
extension Friend {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
