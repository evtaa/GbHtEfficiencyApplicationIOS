//
//  RealmSaveService.swift
//  vk
//
//  Created by Alexandr Evtodiy on 10.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import RealmSwift

class RealmSaveService: SaveServiceInterface  {
     
    let realm: Realm
    
    init () {
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        realm = try! Realm (configuration: config)
        debugPrint(realm.configuration.fileURL ?? "")
    }
    
    //MARK: Function for User
    
    // Saving of users to Realm
    func saveUsers (users: [VkApiUsersItem]) {
        do {
            realm.beginWrite()
            realm.add(users)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    // Uploading of users to Realm by primaryKey
    func updateUsers (users: [VkApiUsersItem]) {
        do {
            realm.beginWrite()
            realm.add (users, update: .all)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    func deleteUser (user: VkApiUsersItem) {
        do {
            guard let user = realm.object(ofType: VkApiUsersItem.self, forPrimaryKey: user.id) else { return }
            realm.beginWrite()
             realm.delete(user.photos)
            realm.delete(user)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    // Loading of users to Realm
    func readUserList () -> [VkApiUsersItem] {
        let listFriendsBD = realm.objects(VkApiUsersItem.self).sorted(byKeyPath: "id")
        
        
        var userList:[VkApiUsersItem] = [VkApiUsersItem] ()
        for object in listFriendsBD {
            let friend: VkApiUsersItem = VkApiUsersItem ()
            friend.id = Int(object.id)
            friend.firstName = object.firstName
            friend.lastName = object.lastName
            friend.cityTitle =  object.cityTitle
            friend.avatarPhotoURL =  object.avatarPhotoURL
            userList.append(friend)
        }
        //return userList.sorted { $0.id < $1.id }
        return userList
    }
    
    //MARK: Function for Photo
    
    // Saving of photos to Realm
    func savePhotos (photos: [VkApiPhotoItem]) {
        do {
            realm.beginWrite()
            realm.add(photos)
            try realm.commitWrite()
        }
        catch {
            print (error)
        }
    }
    
    // Uploading of photos to Realm by primaryKey
    func updatePhotos (photos: [VkApiPhotoItem], ownerID: Int ) {
        
        do {
            guard let user = realm.object(ofType: VkApiUsersItem.self, forPrimaryKey: ownerID) else { return }
            let oldPhotos = realm.objects(VkApiPhotoItem.self).filter("ownerId == %@", ownerID)
            
            realm.beginWrite()
            realm.delete(oldPhotos)
            user.photos.append(objectsIn: photos)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    // Loading of users to Realm
    func readPhotoList (ownerID: Int) -> [VkApiPhotoItem] {
        
        let listPhotosBD = realm.objects(VkApiPhotoItem.self).filter("ownerId == %@", ownerID).sorted(byKeyPath: "id")
        
        var photoList:[VkApiPhotoItem] = [VkApiPhotoItem] ()
        for object in listPhotosBD {
            let photo: VkApiPhotoItem = VkApiPhotoItem ()
            photo.id = Int(object.id)
            photo.date = Int(object.date)
            photo.ownerId = Int(object.ownerId)
            photo.likesCount =  Int(object.likesCount)
            photo.userLike =  Int(object.userLike)
            photo.photoSmallURL =  object.photoSmallURL
            photo.photoMediumURL =  object.photoMediumURL
            photo.photoLargeURL =  object.photoLargeURL
            photoList.append(photo)
        }
        //return photoList.sorted { $0.id < $1.id }
        return photoList
    }
    
    //MARK: Function for Group
    
    // Saving of groups to Realm
    func saveGroups (groups: [VkApiGroupItem]) {
        do {
            realm.beginWrite()
            realm.add(groups)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    // Uploading of groups to Realm by primaryKey
    func updateGroups (groups: [VkApiGroupItem]) {
        do {
            let oldGroups = realm.objects(VkApiGroupItem.self)
            realm.beginWrite()
            realm.delete(oldGroups)
            realm.add (groups, update: .all)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    func deleteGroup (group: VkApiGroupItem) {
        do {
            let deletingGroup = realm.objects(VkApiGroupItem.self).filter("id == %@", group.id)
            realm.beginWrite()
            realm.delete(deletingGroup)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    // Loading of groups to Realm
    func readGroupList () -> [VkApiGroupItem] {
        let listGroupsBD = realm.objects(VkApiGroupItem.self).sorted(byKeyPath: "id")
        
        var groupList:[VkApiGroupItem] = [VkApiGroupItem] ()
        for object in listGroupsBD {
            let group: VkApiGroupItem = VkApiGroupItem ()
            group.id = Int(object.id)
            group.name = object.name
            group.screenName = object.screenName
            group.photoSmallURL =  object.photoSmallURL
            group.photoMediumURL =  object.photoMediumURL
            group.photoLargeURL =  object.photoLargeURL
            groupList.append(group)
        }
        //return userList.sorted { $0.id < $1.id }
        return groupList
    }
    
    //MARK: Function for News
    
    // Saving of users to Realm
    func saveNews (news: [VkApiNewItem]) {

        do {
            realm.beginWrite()
            realm.add (news)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    // Uploading of users to Realm by primaryKey
    func updateNews (news: [VkApiNewItem]) {
        do {
            let deletingNews = realm.objects(VkApiNewItem.self)
            realm.beginWrite()
            realm.delete(deletingNews)
            realm.add (news)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
    }
    
    func deleteNews () {
        
        do {
            let deletingNews = realm.objects(VkApiNewItem.self)
            realm.beginWrite()
            realm.delete(deletingNews)
            try realm.commitWrite()
        }
        catch {
            debugPrint (error)
        }
        
    }
    
    // Loading of users to Realm
    func readNewList () -> [VkApiNewItem] {
        let listNewsBD = realm.objects(VkApiNewItem.self).sorted(byKeyPath: "date")
        let newList = [VkApiNewItem] (listNewsBD)
        return newList
    }
}
