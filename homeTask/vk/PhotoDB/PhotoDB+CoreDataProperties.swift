//
//  PhotoDB+CoreDataProperties.swift
//  vk
//
//  Created by Alexandr Evtodiy on 04.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoDB> {
        return NSFetchRequest<PhotoDB>(entityName: "PhotoDB")
    }

    @NSManaged public var id: Int32
    @NSManaged public var date: Int32
    @NSManaged public var ownerId: Int32
    @NSManaged public var likesCount: Int32
    @NSManaged public var userLike: Int32
    @NSManaged public var photoSmallURL: String?
    @NSManaged public var photoMediumURL: String?
    @NSManaged public var photoLargeURL: String?

}

extension PhotoDB : Identifiable {

}
