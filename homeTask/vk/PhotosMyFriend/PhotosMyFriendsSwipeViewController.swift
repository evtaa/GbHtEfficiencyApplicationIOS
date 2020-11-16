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
    
    @IBOutlet weak var imageView: UIImageView!
    
    var interactiveAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lastName = friendSelected?.lastName,
            let firstName = friendSelected?.firstName {
            self.navigationItem.title = lastName + " " + firstName
        }
        self.imageView.image =  getUIImageFromURL(inputURL: photosFriend![indexImage]!.photoLargeURL)
        self.imageView.isUserInteractionEnabled = true
        
        //addSwipe ()
        
        // Инициализация и добавление параметров жестов
        let directions: [UISwipeGestureRecognizer.Direction] = [.down, .up, .left, .right]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer (target: self, action: #selector(handleSwipe))
            gesture.direction = direction
            self.imageView.addGestureRecognizer(gesture)
        }
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
    
    // MARK: UISwipeGestureRecognizer
    
    @objc func handleSwipe (gesture: UISwipeGestureRecognizer) {
        
        let direction = gesture.direction
        
        switch direction {
            
        case .left:
            
            if indexImage == photosFriend!.count - 1 {
                indexImage = 0
            } else {
                indexImage += 1
            }
            self.imageView.image = getUIImageFromURL(inputURL: photosFriend![indexImage]!.photoLargeURL)
            
            UIView.animate(withDuration: 1) {
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
                
                self.imageView.layer.add (animation, forKey: "pageFlipAnimation")
                // self.containerView.addSubview (self.imageView)
                self.imageView.image =  self.getUIImageFromURL(inputURL: self.photosFriend![self.indexImage]!.photoLargeURL)
               
            }
            
        case .right:
            
            if indexImage == 0 {
                indexImage = photosFriend!.count - 1
            } else {
                indexImage -= 1
            }
            self.imageView.image =  self.getUIImageFromURL(inputURL: self.photosFriend![self.indexImage]!.photoLargeURL)
            
            UIView.animate(withDuration: 1) {
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
                
                self.imageView.layer.add (animation, forKey: "pageFlipAnimation")
                // self.containerView.addSubview (self.imageView)
                self.imageView.image =  self.getUIImageFromURL(inputURL: self.photosFriend![self.indexImage]!.photoLargeURL)
            }
        default:
            break
        }
    }
}
