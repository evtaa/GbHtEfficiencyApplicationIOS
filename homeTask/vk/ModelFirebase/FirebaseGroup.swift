//
//  FirebaseGroup.swift
//  vk
//
//  Created by Alexandr Evtodiy on 18.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import Firebase

class FirebaseGroup {
    var id: Int
    var name: String
    var screenName: String
    var photoSmallURL: String
    var photoMediumURL: String
    var photoLargeURL: String
    var ref: DatabaseReference?
    
    init(id: Int, name: String, screenName: String, photoSmallURL: String, photoMediumURL: String, photoLargeURL: String) {
        self.ref = nil
        self.id = id
        self.name = name
        self.screenName = screenName
        self.photoSmallURL = photoSmallURL
        self.photoMediumURL = photoMediumURL
        self.photoLargeURL = photoLargeURL
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let id = value["id"] as? Int,
            let name = value["name"] as? String,
            let screenName = value["screenName"] as? String,
            let photoSmallURL = value["photoSmallURL"] as? String,
            let photoMediumURL = value["photoMediumURL"] as? String,
            let photoLargeURL = value["photoLargeURL"] as? String else {
            return nil
        }
        self.ref = snapshot.ref
        self.id = id
        self.name = name
        self.screenName = screenName
        self.photoSmallURL = photoSmallURL
        self.photoMediumURL = photoMediumURL
        self.photoLargeURL = photoLargeURL
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "screenName": screenName,
            "photoSmallURL": photoSmallURL,
            "photoMediumURL": photoMediumURL,
            "photoLargeURL": photoLargeURL
        ]
    }
}
