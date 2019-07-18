//
//  Notification+CoreDataProperties.swift
//  To-Do Manager
//
//  Created by burak kaya on 18/07/2019.
//  Copyright © 2019 burak kaya. All rights reserved.
//
//

import Foundation
import CoreData


extension Notification {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notification> {
        return NSFetchRequest<Notification>(entityName: "Notification")
    }

    @NSManaged public var isOn: Bool

}
