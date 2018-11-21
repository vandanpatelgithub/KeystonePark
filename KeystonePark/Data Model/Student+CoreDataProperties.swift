//
//  Student+CoreDataProperties.swift
//  KeystonePark
//
//  Created by Patel, Vandan (ETW - FLEX) on 11/9/18.
//  Copyright © 2018 Patel, Vandan (ETW - FLEX). All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}
