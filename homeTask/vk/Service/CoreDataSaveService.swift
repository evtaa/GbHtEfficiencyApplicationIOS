//
//  CoreDataSaveService.swift
//  vk
//
//  Created by Alexandr Evtodiy on 10.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation

class CoreDataSaveService {
    
    
    
    let vkStack = CoreDataStack(modelName: "VKDataBase")
    
    
    // MARK: User's function
    
    // Function for save user's list
    func saveUsers(users: [VkApiUsersItem]) {
        for user in users {
            let context = vkStack.context
            let userDB = UserDB(context: context)
            userDB.id = Int32(user.id)
            userDB.firstName = user.firstName
            userDB.lastName = user.lastName
            userDB.cityTitle = user.cityTitle
            userDB.avatarPhotoURL = user.avatarPhotoURL
            //storeStack.saveContext()
        }
    }
    // Function for update user's list
    func updateUsers(users: [VkApiUsersItem]) {
        
    }
    
    // Function for load a user's list
    func readUserList() -> [VkApiUsersItem] {
        
        let context = vkStack.context
        let listFriendsBD = (try? context.fetch(UserDB.fetchRequest()) as? [UserDB]) ?? []
        
        var userList:[VkApiUsersItem] = [VkApiUsersItem] ()
        for object in listFriendsBD {
            let friend: VkApiUsersItem = VkApiUsersItem ()
            friend.id = Int(object.id)
            friend.firstName = object.firstName ?? ""
            friend.lastName = object.lastName ?? ""
            friend.cityTitle =  object.cityTitle ?? ""
            friend.avatarPhotoURL =  object.avatarPhotoURL
            userList.append(friend)
        }
        return userList.sorted { $0.id < $1.id }
    }
    
    // MARK: Photos's function
    
    // Function for save photo's list
    func savePhotos (photos: [VkApiPhotoItem]) {
        for photo in photos {
            let context = vkStack.context
            let photoDB = PhotoDB(context: context)
            photoDB.id = Int32(photo.id)
            photoDB.date = Int32(photo.date)
            photoDB.ownerId = Int32(photo.ownerId)
            photoDB.likesCount = Int32(photo.likesCount)
            photoDB.userLike = Int32(photo.userLike)
            photoDB.photoSmallURL = photo.photoSmallURL
            photoDB.photoMediumURL = photo.photoMediumURL
            photoDB.photoLargeURL = photo.photoLargeURL
            //storeStack.saveContext()
        }
    }
    
    // Function for update photo's list
    func updatePhotos (ownerID: Int, photos: [VkApiPhotoItem]) {
        
    }
    
    // Function for load a photo's list
    func readPhotoList (ownerID: Int) -> [VkApiPhotoItem] {
        
        let context = vkStack.context
        let listPhotosBD =  (try? context.fetch(PhotoDB.fetchRequest()) as? [PhotoDB]) ?? []
        
        var photoList:[VkApiPhotoItem] = [VkApiPhotoItem] ()
        for object in listPhotosBD {
            let photo: VkApiPhotoItem = VkApiPhotoItem ()
            photo.id = Int(object.id)
            photo.date = Int(object.date)
            photo.ownerId = Int(object.ownerId)
            photo.likesCount =  Int(object.likesCount)
            photo.userLike =  Int(object.userLike)
            photo.photoSmallURL =  object.photoSmallURL ?? ""
            photo.photoMediumURL =  object.photoMediumURL ?? ""
            photo.photoLargeURL =  object.photoLargeURL ?? ""
            photoList.append(photo)
        }
        return photoList.sorted { $0.id < $1.id }
    }
    
    // MARK: Groups's function
    
    // Function for save group's list
    func saveGroups (groups: [VkApiGroupItem]) {
        for group in groups {
            let context = vkStack.context
            let groupDB = GroupDB (context: context)
            groupDB.id = Int32(group.id)
            groupDB.name = group.name
            groupDB.screenName = group.screenName
            groupDB.photoSmallURL = group.photoSmallURL
            groupDB.photoMediumURL = group.photoMediumURL
            groupDB.photoLargeURL = group.photoLargeURL
            //storeStack.saveContext()
        }
    }
    
    // Function for update group's list
    func updateGroups (groups: [VkApiGroupItem]) {
        
    }
    
    // Function for load a group's list
    func readGroupList () -> [VkApiGroupItem] {
        let context = vkStack.context
        let listGroupsBD = (try? context.fetch(GroupDB.fetchRequest()) as? [GroupDB]) ?? []
        
        var groupList:[VkApiGroupItem] = [VkApiGroupItem] ()
        for object in listGroupsBD {
            let group: VkApiGroupItem = VkApiGroupItem ()
            group.id = Int(object.id)
            group.name = object.name ?? ""
            group.screenName = object.screenName ?? ""
            group.photoSmallURL =  object.photoSmallURL ?? ""
            group.photoMediumURL =  object.photoMediumURL ?? ""
            group.photoLargeURL =  object.photoLargeURL ?? ""
            groupList.append(group)
        }
        return groupList.sorted { $0.id < $1.id }
    }
    
}
