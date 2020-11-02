//
//  GroupDB+CoreDataProperties.swift
//  vk
//
//  Created by Alexandr Evtodiy on 05.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//
//

import Foundation
import CoreData


extension GroupDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupDB> {
        return NSFetchRequest<GroupDB>(entityName: "GroupDB")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var screenName: String?
    @NSManaged public var photoSmallURL: String?
    @NSManaged public var photoMediumURL: String?
    @NSManaged public var photoLargeURL: String?

}

extension GroupDB : Identifiable {

}
