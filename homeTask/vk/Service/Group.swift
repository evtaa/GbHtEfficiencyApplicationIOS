//
//  GroupClass.swift
//  Example
//
//  Created by Alexandr Evtodiy on 01.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import RealmSwift

class VkApiGroupResponse: Decodable {
    let response: VkApiGroupResponseItems
}

class VkApiGroupResponseItems: Decodable {
    let items: [VkApiGroupItem]
}

class VkApiGroupItem: Object, Decodable {
    @objc  dynamic var id: Int = 0
    @objc  dynamic var name: String = ""
    @objc  dynamic var screenName: String = ""
    @objc  dynamic var photoSmallURL: String = ""
    @objc  dynamic var photoMediumURL: String = ""
    @objc  dynamic var photoLargeURL: String = ""
    
    override static func primaryKey() -> String? {
            return "id"
        }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case screen_name
        case photo_50
        case photo_100
        case photo_200
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.screenName = try values.decode(String.self, forKey: .screen_name)
        self.photoSmallURL = try values.decode(String.self, forKey: .photo_50)
        self.photoMediumURL = try values.decode(String.self, forKey: .photo_100)
        self.photoLargeURL = try values.decode(String.self, forKey: .photo_200)
        
        
        debugPrint("id = \(self.id),name = \(self.name),screenName = \(String(describing: self.screenName)), photoSmallURL = \(self.photoSmallURL), photoMediumURL = \(self.photoMediumURL), photoLargeURL = \(self.photoLargeURL)")
        
        
    }
}
