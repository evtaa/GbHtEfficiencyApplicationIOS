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
import PromiseKit

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
    
    // Функция сохранения текущего пользователя приложением
    func saveCurrentUserApplication (userId: Int) {
        firebaseSaveService.saveCurrentUserApplication (id: userId)
    }
    
    // Функция получения списка друзей пользователя
    
    func loadFriendsData(userId: String) -> Promise <[VkApiUsersItem]>{
        
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
        
        let promise = Promise <[VkApiUsersItem]> { resolver in
            Alamofire.request(url, method: .get, parameters: parameters).responseData { response in
                switch response.result{
                case .success(let data):
                    do {
                        let  vkApiUsersResponse = try JSONDecoder().decode (VkApiUsersResponse.self, from: data)
                        let VkApiUsersResponseItems = vkApiUsersResponse.response.items
                        
                        // Заменяем completion на вызов резолвера
                        resolver.fulfill(VkApiUsersResponseItems)
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        
                        debugPrint(DecodingError.dataCorrupted(context))
                    }
                    catch let error {
                        debugPrint("Decoding's error \(url)")
                        debugPrint(error)
                        // Заменяем completion на вызов резолвера
                        resolver.reject(error)
                        
                    }
                case .failure(let error):
                    debugPrint(error)
                    // Заменяем completion на вызов резолвера
                    resolver.reject(error)
                }
            }
        }
        return promise
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
        let myOwnQueue = OperationQueue ()
        
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
        
        let request =  Alamofire.request(url, method: .get, parameters: parameters)
        
        let getDataOperation = GetDataOperation (request: request)
        myOwnQueue.addOperation(getDataOperation)
        
        let parseDataOperation = ParseDataOperation ()
        parseDataOperation.addDependency(getDataOperation)
        myOwnQueue.addOperation(parseDataOperation)
        
        let saveDataToRealmOperation = SaveDataToRealmOperation ()
        saveDataToRealmOperation.addDependency(parseDataOperation)
        OperationQueue.main.addOperation (saveDataToRealmOperation)
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
       
    enum loadNewsDataError: Error {
        case invalidNews
    }
    
    func loadNewsData(startTime: Int = 0, startFrom: String = "", typeNew: [TypeNew], completion: @escaping (Swift.Result <[VkApiNewItem]?, loadNewsDataError>, String?) -> Void){
        var filters: String = ""
        for item in typeNew {
            switch item {
            case .photo :
                filters += item.rawValue + ","
            case .post:
                filters += item.rawValue + ","
            }
        }

        let path = "/newsfeed.get"
        let parameters: Parameters = [
            "filters": filters,
            "return_banned": "0",
            "start_time": String(startTime),
            //"end_time": "",
            //"max_photos": "",
            //"source_ids": "",
            "start_from": startFrom,
            "count": "15",
            //"fields": "",
            //"section": "",
            "v": "5.68",
            "access_token": Session.instance.token!
        ]

        // составляем URL из базового адреса сервиса и конкретного метода
        let url = baseUrl+path
        // делаем запрос
        Alamofire.request(url, method: .get, parameters: parameters).responseData { response in
            switch response.result{
            case .success(let data):
                debugPrint (data)
                var VkApiNextFrom: String?
                var VkApiItems: [VkApiNewItem]?
                var VkApiProfiles: [VkApiUsersItem]?
                var VkApiGroups: [VkApiGroupItem]?
                let dispatchGroup = DispatchGroup ()

                DispatchQueue.global().async (group: dispatchGroup) {
                    do {
                        VkApiItems = try JSONDecoder().decode (VkApiNewsResponseItems.self, from: data).response?.items
                        VkApiNextFrom = try JSONDecoder().decode (VkApiNewsResponseItems.self, from: data).response?.nextFrom
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        debugPrint(DecodingError.dataCorrupted(context))
                    }
                    catch let error {
                        debugPrint("Decoding's error \(url) for items")
                        debugPrint(error)
                        if let data = String(bytes: data, encoding: .utf8) {
                            debugPrint(data)
                        }
                    }
                }
                DispatchQueue.global().async (group: dispatchGroup) {
                    do {
                        VkApiGroups = try JSONDecoder().decode (VkApiNewsResponseGroups.self, from: data).response?.groups
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        debugPrint(DecodingError.dataCorrupted(context))
                    }
                    catch let error {
                        debugPrint("Decoding's error \(url) for groups")
                        debugPrint(error)
                        if let data = String(bytes: data, encoding: .utf8) {
                            debugPrint(data)
                        }
                    }
                }
                DispatchQueue.global().async (group: dispatchGroup) {
                    do {
                        VkApiProfiles = try JSONDecoder().decode (VkApiNewsResponseProfiles.self, from: data).response?.profiles
                    }
                    catch DecodingError.dataCorrupted(let context) {
                        debugPrint(DecodingError.dataCorrupted(context))
                    }
                    catch let error {
                        debugPrint("Decoding's error \(url) for profiles")
                        debugPrint(error)
                        if let data = String(bytes: data, encoding: .utf8) {
                            debugPrint(data)
                        }
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    if let VkApiItems = VkApiItems {
                    for object in VkApiItems {
                        if object.sourceId > 0 {
                            let profile = VkApiProfiles?.filter({$0.id == object.sourceId}).first
                            guard let imageURL = profile?.avatarPhotoURL else {return}
                            object.avatarImageURL = imageURL
                            guard let firstName = profile?.firstName,
                                  let lastName = profile?.lastName
                            else {return}
                            object.nameGroupOrUser = (firstName) + " " + (lastName)
                        }
                        else {
                            let group = VkApiGroups?.filter({$0.id == abs(object.sourceId)}).first
                            guard let imageURL = group?.photoMediumURL else {return}
                            object.avatarImageURL = imageURL
                            guard let name = group?.name else {return}
                            object.nameGroupOrUser = name
                        }
                    }
                    completion(.success(VkApiItems),VkApiNextFrom)
                }
            }
            case .failure(let error):
                completion(.failure(loadNewsDataError.invalidNews),"")
                debugPrint(error)
            }
        }
    }
}


