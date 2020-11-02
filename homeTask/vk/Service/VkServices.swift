//
//  VKServices.swift
//  Example
//
//  Created by Alexandr Evtodiy on 27.09.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import UIKit

protocol SaveServiceInterface {
    func saveUsers (users: [VkApiUsersItem])
    func updateUsers (users: [VkApiUsersItem])
    func readUserList () -> [VkApiUsersItem]
    
    func savePhotos (photos: [VkApiPhotoItem])
    func updatePhotos (photos: [VkApiPhotoItem], ownerID: Int)
    func readPhotoList (ownerID: Int) -> [VkApiPhotoItem]
    
    func saveGroups (groups: [VkApiGroupItem])
    func updateGroups (groups: [VkApiGroupItem])
    func readGroupList () -> [VkApiGroupItem]
    
    
}

class VKService {
    
    // базовый URL сервиса
    let baseUrl = "https://api.vk.com/method"
    let realmSaveService = RealmSaveService ()
    let coreDataSaveService = CoreDataSaveService ()
    let firebaseSaveService = FirebaseSaveService ()
    
    var nextFrom = ""
    
    
    // Функция сохранения текущего пользователя приложением
    func saveCurrentUserApplication (userId: Int) {
        firebaseSaveService.saveCurrentUserApplication (id: userId)
    }
    
    // Функция получения списка друзей пользователя
    func loadFriendsData(userId: String){
        
        let path = "/friends.get"
        let parameters: Parameters = [
            "user_id": userId,
            "order": "name",
            //"list_id": "",
            //"count": "10",
            "offset": "0",
            "fields": "city,photo_100",
            "name_case": "nom",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]
        
        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        Alamofire.request(url, method: .get, parameters: parameters).responseData { [weak self] response in
            switch response.result{
            case .success(let data):
                do {
                    let  vkApiUsersResponse = try JSONDecoder().decode (VkApiUsersResponse.self, from: data)
                    let VkApiUsersResponseItems = vkApiUsersResponse.response.items
                    
                    // Save user array to Database
                    // Working with Realm
                    self?.realmSaveService.updateUsers(users: VkApiUsersResponseItems)
                    debugPrint (data)
                }
                catch DecodingError.dataCorrupted(let context) {
                    debugPrint(DecodingError.dataCorrupted(context))
                }
                catch let error {
                    debugPrint("Decoding's error \(url)")
                    debugPrint(error)
                    debugPrint(String(bytes: data, encoding: .utf8) ?? "")
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    // Функция получения фотографий пользователя
    func loadPhotosData (userId: Int) {
        
        let path = "/photos.get"
        let parameters: Parameters = [
            "owner_id": String(userId),
            "album_id": "wall",
            //"photo_ids": "",
            //"rev": "0",
            "extended": "1",
            //"feed_type": "",
            //"feed": "",
            "photo_sizes": "1",
            "offset": "0",
            //"count": "",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]
        
        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        
        Alamofire.request(url, method: .get, parameters: parameters).responseData { [weak self] response in
            switch response.result{
            case .success(let data):
                do {
                    let  vkApiPhotoResponse = try JSONDecoder().decode (VkApiPhotoResponse.self, from: data)
                    let VkApiPhotosResponseItems = vkApiPhotoResponse.response.items
                    
                    // Save photos array to Database
                    // Working with Realm
                    self?.realmSaveService.updatePhotos(photos: VkApiPhotosResponseItems, ownerID: userId)
                    debugPrint (data)
                }
                catch DecodingError.dataCorrupted(let context) {
                    debugPrint(DecodingError.dataCorrupted(context))
                }
                catch let error {
                    debugPrint("Decoding's error \(url)")
                    debugPrint(error)
                    debugPrint(String(bytes: data, encoding: .utf8) ?? "")
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    // Функция получения списка групп  пользователя
    func loadGroupsData (userId: Int) {
        
        let path = "/groups.get"
        let parameters: Parameters = [
            "user_id": String(userId),
            "extended": "1",
            //"filter": "0",
            //"fields": "0",
            //"offset": "0",
            //"count": "50",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]
        
        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        Alamofire.request(url, method: .get, parameters: parameters).responseData { [weak self] response in
            switch response.result{
            case .success(let data):
                do {
                    let  vkApiGroupResponse = try JSONDecoder().decode (VkApiGroupResponse.self, from: data)
                    let VkApiGroupsResponseItems = vkApiGroupResponse.response.items
                    
                    // Save group array to Database
                    //                    // Working with Realm
                    //                    self?.realmSaveService.updateGroups(groups:VkApiGroupsResponseItems)
                    
                    // Working with Firebase
                    self?.firebaseSaveService.updateGroups(groups: VkApiGroupsResponseItems)
                    
                    debugPrint (data)
                }
                catch DecodingError.dataCorrupted(let context) {
                    debugPrint(DecodingError.dataCorrupted(context))
                }
                catch let error {
                    debugPrint("Decoding's error \(url)")
                    debugPrint(error)
                    debugPrint(String(bytes: data, encoding: .utf8) ?? "")
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    // Получения списка групп по заданной подстроке
    func loadSearchGroupsData (search: String, completion: @escaping ([VkApiGroupItem]) -> Void) {
        
        let path = "/groups.search"
        let parameters: Parameters = [
            "q": search,
            //"type": "group",
            //"country_id": "0",
            //"city_id": "0",
            //"future": "0",
            //"market": "0",
            //"sort": "0",
            //"offset": "3",
            "count": "5",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]
        
        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        Alamofire.request(url, method: .get, parameters: parameters).responseData { response in
            switch response.result{
            case .success(let data):
                do {
                    let  vkApiSearchGroupResponse = try JSONDecoder().decode (VkApiGroupResponse.self, from: data)
                    completion (vkApiSearchGroupResponse.response.items)
                    debugPrint (data)
                }
                catch DecodingError.dataCorrupted(let context) {
                    debugPrint(DecodingError.dataCorrupted(context))
                }
                catch let error {
                    debugPrint("Decoding's error \(url)")
                    debugPrint(error)
                    debugPrint(String(bytes: data, encoding: .utf8) ?? "")
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func loadNewsData(){
        let path = "/newsfeed.get"
        let parameters: Parameters = [
            "filters": "post, photo",
            "return_banned": "0",
            //"start_time": "",
            //"end_time": "",
            //"max_photos": "",
            //"source_ids": "",
            // "start_from": nextFrom,
            "count": "50",
            //"fields": "",
            //"section": "",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]
        
        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        Alamofire.request(url, method: .get, parameters: parameters).responseData { [weak self] response in
            switch response.result{
            case .success(let data):
                do {
                    debugPrint (data)
                    let  vkApiNewsResponse = try JSONDecoder().decode (VkApiNewsResponse.self, from: data)
                    let VkApiNewsResponseItems = vkApiNewsResponse.response.items
                    let VkApiNewsResponseProfiles = vkApiNewsResponse.response.profiles
                    let VkApiNewsResponseGroups = vkApiNewsResponse.response.groups
                    for object in VkApiNewsResponseItems {
                        if object.sourceId > 0 {
                            let profile = VkApiNewsResponseProfiles.filter({$0.id == object.sourceId}).first
                            object.avatarImageURL = profile?.avatarPhotoURL ?? ""
                            object.nameGroupOrUser = (profile?.firstName ?? "") + " " + (profile?.lastName ?? "")
                        }
                        else {
                            let group = VkApiNewsResponseGroups.filter({$0.id == abs(object.sourceId)}).first
                            object.avatarImageURL = group?.photoMediumURL ?? ""
                            object.nameGroupOrUser = group?.name ?? ""
                        }
                    }
                    // Save user array to Database
                    // Working with Realm
                    self?.realmSaveService.updateNews(news: VkApiNewsResponseItems)
                    debugPrint (data)
                }
                catch DecodingError.dataCorrupted(let context) {
                    debugPrint(DecodingError.dataCorrupted(context))
                }
                catch let error {
                    debugPrint("Decoding's error \(url)")
                    debugPrint(error)
                    debugPrint(String(bytes: data, encoding: .utf8) ?? "")
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
}


