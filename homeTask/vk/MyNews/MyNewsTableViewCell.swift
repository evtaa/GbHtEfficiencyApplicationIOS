//
//  MyNewsTableViewCell.swift
//  vk
//
//  Created by Alexandr Evtodiy on 01.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit

class MyNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarShadow: UIView!
    @IBOutlet weak var avatarMyFriendNews: UIImageView!
    @IBOutlet weak var nameMyFriendNews: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var contentLabelNews: UILabel!
    @IBOutlet weak var likeUIControl: LikeUIControl!
    @IBOutlet weak var commentShareUIControl: CommentShareUIControl!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter ()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAvatar ()
        // Initialization code
    }
    
    func setupAvatar () {
        avatarMyFriendNews.layer.cornerRadius = avatarMyFriendNews.frame.height/2
        let f = avatarMyFriendNews.frame
        avatarShadow.frame = CGRect (x: f.origin.x,
                                     y: f.origin.y,
                                     width: f.width,
                                     height: f.height)
        
        avatarShadow.layer.shadowColor = UIColor.black.cgColor
        avatarShadow.layer.shadowOpacity = 0.5
        avatarShadow.layer.shadowRadius = 10
        avatarShadow.layer.shadowOffset = CGSize(width: 3, height: 3)
        avatarShadow.layer.cornerRadius = avatarShadow.bounds.height/2
    }
    
    func setup (new: VkApiNewItem, photoService: PhotoService?, indexPath: IndexPath) {
        if let avatarImageURL = new.avatarImageURL {
            avatarMyFriendNews.image = photoService?.photo(atIndexpath: indexPath, byUrl: avatarImageURL)
        }     
        
        nameMyFriendNews.text = new.nameGroupOrUser
        let dateSince1970 = Date(timeIntervalSince1970: TimeInterval(new.date))
        date.text = dateFormatter.string(from: dateSince1970)
        
        contentLabelNews.text = new.text

        let userLike = new.userLikes != 0
        likeUIControl.likeButton.setTitle(userLike ? "❤" : "💜", for: .normal)
        let likesCount = new.likesCount
        likeUIControl.likeLabel.text = String (likesCount)
        let commentCount = new.commentsCount
        commentShareUIControl.commentCount.text = String(commentCount)
        let shareCount = new.repostCount
        commentShareUIControl.shareCount.text = String(shareCount)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
