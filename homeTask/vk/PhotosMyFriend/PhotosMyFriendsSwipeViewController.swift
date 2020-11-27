//
//  PhotosMyFriendsSwipeViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 08.09.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import RealmSwift

class PhotosMyFriendsSwipeViewController: UIViewController {
    
    var friendSelected : VkApiUsersItem?
    var photosFriend : [VkApiPhotoItem?]?
    var indexImage : Int = 0
    @IBOutlet weak var likeUIControl: LikeUIControl!
    @IBOutlet weak var commentShareUIControl: CommentShareUIControl!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var interactiveAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController ()
        setupSwipeGestureRecognizer ()
    }
    
    private func setupViewController () {
        if let lastName = friendSelected?.lastName,
           let firstName = friendSelected?.firstName {
            self.navigationItem.title = lastName + " " + firstName
        }
        if let url = photosFriend?[indexImage]?.photoLargeURL {
            self.imageView.load (url: url)
        }
        if let likesCount = photosFriend?[indexImage]?.likesCount {
            self.likeUIControl.likeLabel.text = String (likesCount)
        }
        if let repostsCount = photosFriend?[indexImage]?.repostsCount {
            self.commentShareUIControl.shareCount.text = String(repostsCount)
        }
        if let commentsCount = photosFriend?[indexImage]?.commentsCount {
            self.commentShareUIControl.commentCount.text = String(commentsCount)
        }
    }
    
    private func setupSwipeGestureRecognizer () {
        self.imageView.isUserInteractionEnabled = true
        // Инициализация и добавление параметров жестов
        let directions: [UISwipeGestureRecognizer.Direction] = [.down, .up, .left, .right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer (target: self, action: #selector(handleSwipe))
            gesture.direction = direction
            self.imageView.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: UISwipeGestureRecognizer
    
    @objc func handleSwipe (gesture: UISwipeGestureRecognizer) {
        
        let direction = gesture.direction
        guard let photosFriend = photosFriend else {return}
        switch direction {
        case .left:
            
            if indexImage == photosFriend.count - 1 {
                indexImage = 0
            } else {
                indexImage += 1
            }
            if let url = photosFriend[indexImage]?.photoLargeURL {
                self.imageView.load(url: url)
            }
            
            UIView.animate(withDuration: 1) { [weak self] in
                let animation = CATransition ()
                animation.duration = 1
                animation.startProgress = 0.5
                animation.endProgress = 1
                animation.type = CATransitionType (rawValue: "pageCurl")
                animation.subtype = CATransitionSubtype.fromRight
                animation.isRemovedOnCompletion = false
                animation.fillMode = CAMediaTimingFillMode (rawValue: "extended")
                animation.isRemovedOnCompletion = false
                animation.autoreverses = false
                
                self?.imageView.layer.add (animation, forKey: "pageFlipAnimation")
                // self.containerView.addSubview (self.imageView)
                guard let indexImage = self?.indexImage else {return}
                if let url = self?.photosFriend?[indexImage]?.photoLargeURL {
                    self?.imageView.load(url: url)
                }
                if let likesCount = self?.photosFriend?[indexImage]?.likesCount {
                    self?.likeUIControl.likeLabel.text = String (likesCount)
                }
                if let repostsCount = self?.photosFriend?[indexImage]?.repostsCount {
                    self?.commentShareUIControl.shareCount.text = String (repostsCount)
                }
                if let commentsCount = self?.photosFriend?[indexImage]?.commentsCount {
                    self?.commentShareUIControl.commentCount.text = String (commentsCount)
                }
            }
            
        case .right:
            if indexImage == 0 {
                indexImage = photosFriend.count - 1
            } else {
                indexImage -= 1
            }
            if let url = photosFriend[indexImage]?.photoLargeURL {
                self.imageView.load(url: url)
            }
            
            UIView.animate(withDuration: 1) { [weak self] in
                let animation = CATransition ()
                animation.duration = 1
                animation.startProgress = 0.5
                animation.endProgress = 1
                animation.type = CATransitionType (rawValue: "pageCurl")
                animation.subtype = CATransitionSubtype.fromLeft
                animation.isRemovedOnCompletion = false
                animation.fillMode = CAMediaTimingFillMode (rawValue: "extended")
                animation.isRemovedOnCompletion = false
                animation.autoreverses = false
                
                self?.imageView.layer.add (animation, forKey: "pageFlipAnimation")
                // self.containerView.addSubview (self.imageView)
                if let indexImage = self?.indexImage,
                   let url = self?.photosFriend?[indexImage]?.photoLargeURL{
                        self?.imageView.load(url: url)
                }
            }
        default:
            break
        }
    }
}
