//
//  PhotosMyFriendCollectionViewCell.swift
//  vk
//
//  Created by Alexandr Evtodiy on 07.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit

class PhotosMyFriendCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var likeUIControl: LikeUIControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func setup (photoFriend: VkApiPhotoItem) {
        
        let userLike = photoFriend.userLike != 0
        likeUIControl.likeButton.setTitle(userLike ? "❤" : "💜", for: .normal)  
        let likesCount = photoFriend.likesCount
        likeUIControl.likeLabel.text = String (likesCount)
        photoImageView.load(url: photoFriend.photoLargeURL)
        
    }
}
