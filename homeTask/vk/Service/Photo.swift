//
//  PhotoClass2.swift
//  Example
//
//  Created by Alexandr Evtodiy on 01.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import RealmSwift

class VkApiPhotoResponse: Decodable {
    let response: VkApiPhotoResponseItems
}

class VkApiPhotoResponseItems: Decodable {
    let items: [VkApiPhotoItem]
}

class VkApiPhotoItem: Object, Decodable {

    @objc  dynamic var id: Int = 0
    @objc  dynamic var date: Int = 0
    @objc  dynamic var ownerId: Int = 0

    @objc  dynamic var likesCount: Int = 0
    @objc  dynamic var userLike: Int = 0

    @objc  dynamic var photoSmallURL: String = ""
    @objc  dynamic var photoMediumURL: String = ""
    @objc  dynamic var photoLargeURL: String = ""
    
    //@objc  dynamic var owner: VkApiUsersItem?
    
    override static func primaryKey() -> String? {
            return "id"
        }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case likes
        case sizes
        case owner_id
    }
    
    enum LikesKeys: String, CodingKey {
        case likes_count = "count"
        case user_likes
    }

    enum SizesKeys: String, CodingKey {
        case type
        case src
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try values.decode(Int.self, forKey: .date)
        self.id = try values.decode(Int.self, forKey: .id)
        self.ownerId = try values.decode(Int.self, forKey: .owner_id)

        let likes = try values.nestedContainer(keyedBy: LikesKeys.self, forKey: .likes)
        self.likesCount = try likes.decode(Int.self, forKey: .likes_count)
        self.userLike = try likes.decode(Int.self, forKey: .user_likes)
        
        var sizes = try values.nestedUnkeyedContainer(forKey: .sizes)
        for _ in 0..<(sizes.count ?? 0) {
            let firstSizeValues = try sizes.nestedContainer(keyedBy: SizesKeys.self)
            let type = try firstSizeValues.decode(String.self, forKey: .type)
            switch (type) {
                case "s":
                    self.photoSmallURL = try firstSizeValues.decode(String.self, forKey: .src)
                case "m":
                    self.photoMediumURL = try firstSizeValues.decode(String.self, forKey: .src)
                case "x":
                    self.photoLargeURL = try firstSizeValues.decode(String.self, forKey: .src)
                default:
                    break
            }
        }
        
        debugPrint("date = \(self.date),id = \(self.id),ownerId = \(self.ownerId), likesCount = \(self.likesCount), userLikes = \(self.userLike), photoSmallURL = \(self.photoSmallURL), photoMediumURL = \(self.photoMediumURL), photoLargeURL = \(self.photoLargeURL)")
    }
}
