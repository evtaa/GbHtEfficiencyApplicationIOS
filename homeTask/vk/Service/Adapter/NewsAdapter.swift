//
//  NewsAdapter.swift
//  vk
//
//  Created by Alexandr Evtodiy on 23.12.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import RealmSwift


enum TypeNew: String {
    case post
    case photo
}

enum getNewsDataFromRealmError: Error {
    case invalidNewsFromRealm
}

class NewsAdapter {

    private var nextFrom: String = ""
    private let vkService = VKService ()
    private var notificationToken: NotificationToken?

    func getNewsData (startTime: Int = 0, startFrom: String = "", typeNew: TypeNew ..., completion: @escaping (Swift.Result <[VkApiNewItem]?, getNewsDataFromRealmError>, String?) -> Void) {

        guard let realm = try? Realm() else { return }
        let objects = realm.objects(VkApiNewItem.self)
        if let notificationToken = self.notificationToken {
            notificationToken.invalidate()
        }
        let token = objects.observe { [weak self] (changes: RealmCollectionChange) in

            switch changes {
            case .initial:
                break
            case .update (let results, _, _, _):
                guard !results.isInvalidated else {return}
                //let myNews = [VkApiNewItem](results)
                let myNews = self?.transRealmAnswerToArray(answer: results)
                debugPrint(".update : \(myNews?.count) myNews loaded from DB")
                if let notificationToken = self?.notificationToken {
                    notificationToken.invalidate()
                }
                completion(.success(myNews), self?.nextFrom)
            case .error(let error):
                completion(.failure(getNewsDataFromRealmError.invalidNewsFromRealm), "")
                fatalError("\(error)")
            }
        }
        self.notificationToken = token
        
        vkService.loadNewsData(startTime: startTime, startFrom: startFrom, typeNew: typeNew) { [weak self] result,nextFrom  in
            guard let self = self else { return }
            
            switch result {
            case .success (let news):
                // проверяем, что более свежие новости действительно есть
                guard news!.count > 0 else { return }
                // Save user array to Database
                // Working with Realm
                
                                // Если не было рефреша и был первый запрос после загрузки приложения
                                if let nextFrom = nextFrom {
                                    self.nextFrom = nextFrom
                                }
                
                //Если был рефреш
                if let news = news {
                    self.vkService.realmSaveService.saveNews(news: news)
                }
            case .failure (let error):
                debugPrint ("Error of News")
                debugPrint (error)
            }
        }
    }

    private func transRealmAnswerToArray (answer: Results<VkApiNewItem>) -> [VkApiNewItem]  {
        var array:[VkApiNewItem] = [VkApiNewItem] ()
        for object in answer {
            let new: VkApiNewItem = VkApiNewItem ()
            new.avatarImageURL = object.avatarImageURL
            new.nameGroupOrUser = object.nameGroupOrUser
            new.type = object.type
            new.sourceId = object.sourceId
            new.date = object.date
            new.text =  object.text
            new.commentsCount =  object.commentsCount
            new.likesCount =  object.likesCount
            new.userLikes = object.userLikes
            new.repostCount = object.repostCount
            new.userReposted = object.userReposted
            new.typeAttachment =  object.typeAttachment
            new.listPhotoImageURL =  object.listPhotoImageURL
            new.listPhotoAttachmentImageURL = object.listPhotoAttachmentImageURL
            array.append(new)
        }
        return array
    }
}
