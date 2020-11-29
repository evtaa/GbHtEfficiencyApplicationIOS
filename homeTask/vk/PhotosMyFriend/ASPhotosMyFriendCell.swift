//
//  ASPhotosMyFriendCell.swift
//  vk
//
//  Created by Alexandr Evtodiy on 28.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import UIKit
import AsyncDisplayKit

class ASPhotosMyFriendCell: ASCellNode {
    
    private let photo: VkApiPhotoItem
    private let imagePhotoNode = ASNetworkImageNode ()
 
    init (photo: VkApiPhotoItem) {
        self.photo = photo
        super.init()
        backgroundColor = UIColor.white
        setupSubNodes ()
    }
 
    private func setupSubNodes () {
        imagePhotoNode.url = URL(string: photo.photoLargeURL)
        addSubnode(imagePhotoNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let width  = constrainedSize.max.width
        imagePhotoNode.style.preferredSize = CGSize (width: width, height: width*CGFloat((photo.height/photo.width)))
        return ASWrapperLayoutSpec(layoutElement: imagePhotoNode)
    }
}
