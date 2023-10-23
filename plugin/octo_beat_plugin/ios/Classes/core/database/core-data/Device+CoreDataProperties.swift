//
//  Device+CoreDataProperties.swift
//  
//
//  Created by Manh Tran on 2021-06-26.
//
//

import Foundation
import CoreData


extension Device {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Device> {
        return NSFetchRequest<Device>(entityName: "Device")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var studyStatus: String?

}
