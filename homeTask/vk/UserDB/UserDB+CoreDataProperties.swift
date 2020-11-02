//
//  UserDB+CoreDataProperties.swift
//  vk
//
//  Created by Alexandr Evtodiy on 04.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//
//

import Foundation
import CoreData


extension UserDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserDB> {
        return NSFetchRequest<UserDB>(entityName: "UserDB")
    }

    @NSManaged public var avatarPhotoURL: String?
    @NSManaged public var cityTitle: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: Int32
    @NSManaged public var lastName: String?

}

extension UserDB : Identifiable {

}
