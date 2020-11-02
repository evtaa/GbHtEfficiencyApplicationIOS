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
        photoImageView.image = getUIImageFromURL(inputURL:photoFriend.photoLargeURL)

    }
    
    // MARK: CustomFunction
    
    func getUIImageFromURL ( inputURL: String) -> UIImage {
        let url = URL(string: inputURL)
            if let data = try? Data(contentsOf: url!)
            {
                return UIImage(data: data) ?? UIImage()
            }
        return  UIImage()
    }
    
    
}
