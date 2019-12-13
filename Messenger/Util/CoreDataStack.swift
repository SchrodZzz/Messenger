//
//  CoreDataStack.swift
//  Messenger
//
//  Created by Suspect on 08.12.2019.
//  Copyright © 2019 Andrey Ivshin. All rights reserved.
//

import CoreData

class CoreDataStack {

    var context: NSManagedObjectContext
    var coordinator: NSPersistentStoreCoordinator

    init() {
        let model = NSManagedObjectModel.mergedModel(from: nil)!
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let storeURL = url.appendingPathComponent("Messenger.sqlite")

        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)

        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
    }
}

