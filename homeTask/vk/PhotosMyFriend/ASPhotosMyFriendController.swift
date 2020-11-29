//
//  ASPhotosMyFriendController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 28.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
//import UIKit
import AsyncDisplayKit
import RealmSwift

class  ASPhotosMyFriendController : ASDKViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
    
    var newRefreshControl = UIRefreshControl()
    
    var friendSelected : VkApiUsersItem?
    var photosFriend = [VkApiPhotoItem?] ()

    let vkService = VKService()
    var token: NotificationToken?
    
    var collectionNode: ASCollectionNode
        
    override init() {
            let screenSize: CGRect = UIScreen.main.bounds
            let effectiveWidth = screenSize.width - 20
            let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            flowLayout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 40, right: 4)
            flowLayout.itemSize = CGSize(width: effectiveWidth / 2, height: effectiveWidth / 2)

            collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: flowLayout)
            
            super.init(node: collectionNode)
            
            collectionNode.delegate = self
            collectionNode.dataSource = self
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupRefreshControl ()
        setupCollectionNode ()
        // отправим запрос для получения  фотографий пользователя
        fetchPhotosData ()
        pairTableAndRealm { [weak self] photosFriend in
            guard let collectionNode = self?.collectionNode else { return }
            self?.photosFriend = photosFriend
            collectionNode.reloadData()
            self?.newRefreshControl.endRefreshing()
        }
    }
    
    private func setupCollectionNode () {
        
        //collectionNode.addSubnode(newRefreshControl)
        
        // Выставляем заголовок в навигации
        if let lastName = friendSelected?.lastName,
           let firstName = friendSelected?.firstName {
            self.navigationItem.title = lastName + " " + firstName
        }
}
    private func setupRefreshControl () {
        // Configure Refresh Control
        newRefreshControl.addTarget(self, action: #selector(refreshPhotosData(_:)), for: .valueChanged)
        newRefreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 0.7)
    }
    
    @objc func refreshPhotosData(_ sender: Any) {
        fetchPhotosData ()
    }
    
    private func fetchPhotosData () {
        DispatchQueue.global().async { [weak self] in
            guard let friendSelectedId = self?.friendSelected?.id else {return}
            self?.vkService.loadPhotosData(userId: friendSelectedId)
        }
    }
    
    // MARK: Pair Table and Realm
    
    func pairTableAndRealm(completion: @escaping  ([VkApiPhotoItem]) -> Void) {
        guard let realm = try? Realm(),
              let user = realm.object(ofType: VkApiUsersItem.self, forPrimaryKey: friendSelected!.id) else { return }
        let objects = user.photos
        token = objects.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial (let results):
                guard !results.isInvalidated else {return}
                //let photosFriend = [VkApiPhotoItem](results)
                let photosFriend = self.transRealmAnswerToArray (answer: results)
                debugPrint(".initial : \(photosFriend.count) photosFriend loaded from DB")
                completion(photosFriend)
            case .update (let results, _, _, _):
                guard !results.isInvalidated else {return}
                //let photosFriend = [VkApiPhotoItem](results)
                let photosFriend = self.transRealmAnswerToArray (answer: results)
                debugPrint(".update : \(photosFriend.count) photosFriend loaded from DB")
                completion(photosFriend)
            case .error(let error):
                debugPrint(".error")
                debugPrint(error)
            }
        }
    }
    
    private func transRealmAnswerToArray (answer: List<VkApiPhotoItem>) -> [VkApiPhotoItem]  {
        var array:[VkApiPhotoItem] = [VkApiPhotoItem] ()
        for object in answer {
            let photo: VkApiPhotoItem = VkApiPhotoItem ()
            photo.id = Int(object.id)
            photo.date = Int(object.date)
            photo.ownerId = Int(object.ownerId)
            photo.likesCount =  Int(object.likesCount)
            photo.userLike =  Int(object.userLike)
            photo.photoSmallURL =  object.photoSmallURL
            photo.photoMediumURL =  object.photoMediumURL
            photo.photoLargeURL =  object.photoLargeURL
            photo.commentsCount = object.commentsCount
            photo.repostsCount = object.repostsCount
            photo.width = object.width
            photo.height = object.height
            array.append(photo)
        }
        return array
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return self.photosFriend.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        guard self.photosFriend.count > indexPath.row,
              let photo = photosFriend [indexPath.row] else { return { ASCellNode ()} }

        let cellNodeBlock = {() -> ASCellNode in
            let node  = ASPhotosMyFriendCell(photo: photo)
            return node
        }
        return cellNodeBlock
    }
    
}
