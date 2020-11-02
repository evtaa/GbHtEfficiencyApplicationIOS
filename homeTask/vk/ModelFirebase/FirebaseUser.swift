//
//  FirebaseUser.swift
//  vk
//
//  Created by Alexandr Evtodiy on 17.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUser {
    var id: Int
    var ref: DatabaseReference?
    
    init(id: Int) {
        self.ref = nil
        self.id = id
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let id = value["id"] as? Int else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.id = id
    }
    
    func toAnyObject() -> [String: Any] {
        return [
            "id": id
        ]
    }
}

