//
//  Task+CoreDataProperties.swift
//  To-Do Manager
//
//  Created by burak kaya on 16/07/2019.
//  Copyright © 2019 burak kaya. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var title: String?
    @NSManaged public var date: String?
    @NSManaged public var category: String?
    @NSManaged public var colour: String?

}
