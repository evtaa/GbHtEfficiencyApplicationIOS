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
    @IBOutlet weak var commentShareUIControl: CommentShareUIControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    func setup (photoFriend: VkApiPhotoItem, photoService: PhotoService?, indexPath: IndexPath) {
            photoImageView.image = photoService?.photo(atIndexpath: indexPath, byUrl: photoFriend.photoLargeURL)
        
        let userLike = photoFriend.userLike != 0
        likeUIControl.likeButton.setTitle(userLike ? "❤" : "💜", for: .normal)  
        let likesCount = photoFriend.likesCount
        likeUIControl.likeLabel.text = String (likesCount)
        
        let repostsCount = photoFriend.repostsCount
        commentShareUIControl.shareCount.text = String (repostsCount)
        
        let commentsCount = photoFriend.commentsCount
        commentShareUIControl.commentCount.text = String (commentsCount)
    }
}
