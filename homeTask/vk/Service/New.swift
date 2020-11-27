//
//  News.swift
//  vk
//
//  Created by Alexandr Evtodiy on 20.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import RealmSwift

class VkApiNewsResponseItems: Decodable {
    let response: VkApiNewsItems?
    enum CodingKeys: String, CodingKey {
           case response
       }
       init(response: VkApiNewsItems?) {
           self.response = response
       }
}
class VkApiNewsItems: Decodable {
    var items: [VkApiNewItem]?
    var nextFrom: String?
    enum CodingKeys: String, CodingKey {
           case items
           case nextFrom = "next_from"
       }
    init(items: [VkApiNewItem]?, nextFrom: String?) {
           self.items = items
           self.nextFrom = nextFrom
       }
}

class VkApiNewsResponseGroups: Decodable {
    let response: VkApiNewsGroups?
    enum CodingKeys: String, CodingKey {
           case response
       }
       init(response: VkApiNewsGroups?) {
           self.response = response
       }
}
class VkApiNewsGroups: Decodable {
    let groups: [VkApiGroupItem]?
    enum CodingKeys: String, CodingKey {
           case groups
       }
    init(groups: [VkApiGroupItem]?) {
           self.groups = groups
       }
}

class VkApiNewsResponseProfiles: Decodable {
    let response: VkApiNewsProfiles?
    enum CodingKeys: String, CodingKey {
           case response
       }
       init(response: VkApiNewsProfiles?) {
           self.response = response
       }
}
class VkApiNewsProfiles: Decodable {
    let profiles: [VkApiUsersItem]?
    enum CodingKeys: String, CodingKey {
           case profiles
       }
    init(profiles: [VkApiUsersItem]?) {
           self.profiles = profiles
       }
}

class VkApiNewItem: Object, Decodable {

    @objc dynamic var id: Int = 0
    @objc static  var countNews: Int = 0
    @objc dynamic var isExpanded: Bool = false
    @objc dynamic var avatarImageURL: String?
    @objc dynamic var nameGroupOrUser: String?
    @objc dynamic var type: String?
    @objc dynamic var sourceId: Int = 0
    @objc dynamic var date: Int = 0
    @objc dynamic var text: String?
    @objc dynamic var commentsCount: Int = 0
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var userLikes: Int = 0
    @objc dynamic var repostCount: Int = 0
    @objc dynamic var userReposted: Int = 0
    @objc dynamic var typeAttachment: String?
    dynamic var listPhotoAttachmentImageURL = List<String?>()
    dynamic var listPhotoImageURL = List<String?>()
    dynamic var listHeightPhotoAttachment = List<String?>()
    dynamic var listWidthPhotoAttachment = List<String?>()
    dynamic var listHeightPhotoImage = List<String?>()
    dynamic var listWidthPhotoImage = List<String?>()
    
    override static func primaryKey() -> String? {
            return "id"
        }

    enum CodingKeys: String, CodingKey {
        case type
        case source_id
        case date
        case text
        case comments
        case likes
        case reposts
        case attachments
        case photos
    }
    
    enum CommentsKeys: String, CodingKey {
        case count
    }
    enum LikesKeys: String, CodingKey {
        case count
        case user_likes
    }
    enum RepostsKeys: String, CodingKey {
        case count
        case user_reposted
    }
    enum AttachmentsKeys: String, CodingKey {
        case type
        case photo
        //case video
    }
    enum PhotoKeys: String, CodingKey {
        case photo_604
        case height
        case width
    }
    enum PhotosKeys: String, CodingKey {
        case items
    }
    
    override init() {
        super.init()
        Self.countNews = Self.countNews + 1
        self.id = Self.countNews
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try? values.decode(String.self, forKey: .type)
        self.sourceId = try values.decode(Int.self, forKey: .source_id)
        self.date = try values.decode(Int.self, forKey: .date)
        
        self.text = try? values.decode(String.self, forKey: .text)

        
        do{
            let comments = try values.nestedContainer(keyedBy: CommentsKeys.self, forKey: .comments)
            self.commentsCount = try comments.decode(Int.self, forKey: .count)
        }
        catch {}
        
        do{
        let likes = try values.nestedContainer(keyedBy: LikesKeys.self, forKey: .likes)
        self.likesCount = try likes.decode(Int.self, forKey: .count)
        self.userLikes = try likes.decode(Int.self, forKey: .user_likes)
        }
        catch{}
        
        do{
        let reposts = try values.nestedContainer(keyedBy: RepostsKeys.self, forKey: .reposts)
        self.repostCount = try reposts.decode(Int.self, forKey: .count)
        self.userReposted = try reposts.decode(Int.self, forKey: .user_reposted)
        }
        catch {}
        
        var attachments = try? values.nestedUnkeyedContainer(forKey: .attachments)
        for _ in 0..<(attachments?.count ?? 0){
            let firstAttachmentsValues = try? attachments?.nestedContainer(keyedBy: AttachmentsKeys.self)
            self.typeAttachment = try? firstAttachmentsValues?.decode(String.self, forKey: .type)
            switch (typeAttachment) {
            case "photo":
                let photo = try? firstAttachmentsValues?.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo)
                
                let photoImageURL = try? photo?.decode(String.self, forKey: .photo_604)
                self.listPhotoAttachmentImageURL.append(photoImageURL)
                
                let heightPhotoImage = try? photo?.decode(String.self, forKey: .height)
                self.listHeightPhotoAttachment.append(heightPhotoImage)
                
                let widthPhotoImage = try? photo?.decode(String.self, forKey: .width)
                self.listWidthPhotoAttachment.append(widthPhotoImage)
                
                break
            default: break
            }
        }
        
        let photos = try? values.nestedContainer(keyedBy: PhotosKeys.self, forKey: .photos)
        var items = try? photos?.nestedUnkeyedContainer(forKey: .items)
        for _ in 0..<(items?.count ?? 0){
            let firstItemsValues = try? items?.nestedContainer(keyedBy: PhotoKeys.self)
            
            let photoImageURL = try? firstItemsValues?.decode(String.self, forKey: .photo_604)
            self.listPhotoImageURL.append(photoImageURL)
            
            let heightPhotoImage = try? firstItemsValues?.decode(String.self, forKey: .height)
            self.listHeightPhotoImage.append(heightPhotoImage)
            
            let widthPhotoImage = try? firstItemsValues?.decode(String.self, forKey: .width)
            self.listWidthPhotoImage.append(widthPhotoImage)
        }
    }
}
