//
//  FIrebaseSaveService.swift
//  vk
//
//  Created by Alexandr Evtodiy on 18.10.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseSaveService: SaveServiceInterface {
    
//    let refBranchGroups = Database.database().reference (withPath: "groups")
    let refBranchGroups = Database.database().reference (withPath: "users/\(String (Session.instance.userId!))/groups")
    let refBranchUsers = Database.database().reference (withPath: "users")
    
    func saveUsers(users: [VkApiUsersItem]) {
        
    }
    
    func updateUsers(users: [VkApiUsersItem]) {
        
    }
    
    func readUserList() -> [VkApiUsersItem] {
        return []
    }
    
    func savePhotos(photos: [VkApiPhotoItem]) {
        
    }
    
    func updatePhotos(photos: [VkApiPhotoItem], ownerID: Int) {
        
    }
    
    func readPhotoList(ownerID: Int) -> [VkApiPhotoItem] {
        return []
    }
    
    func saveGroups(groups: [VkApiGroupItem]) {
        
    }
    
    func updateGroups(groups: [VkApiGroupItem]) {
        
        for object in groups {
            // создаем объект который запишем в базу
            let firebaseGroup = FirebaseGroup (id: object.id, name: object.name, screenName: object.screenName, photoSmallURL: object.photoSmallURL, photoMediumURL: object.photoMediumURL, photoLargeURL: object.photoLargeURL)
            // создаем ссылку в базе на будущий объект и даем ему название
            let groupRef = self.refBranchGroups.child (String(object.id).lowercased ())
            // по ссылке записываем объект в базу
            groupRef.setValue(firebaseGroup.toAnyObject())
        }
    }
    
    func readGroupList() -> [VkApiGroupItem] {
        return []
    }
    
    func saveCurrentUserApplication (id: Int) {
        
        // создаем объект который запишем в базу
        let firebaseUser = FirebaseUser (id: id)
        // создаем ссылку в базе на будущий объект и даем ему название
        let userRef = self.refBranchUsers.child (String(id).lowercased ())
        // по ссылке записываем объект в базу
        userRef.setValue(firebaseUser.toAnyObject())
    }
    
}
