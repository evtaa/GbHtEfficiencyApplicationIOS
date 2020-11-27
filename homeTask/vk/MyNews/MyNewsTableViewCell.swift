//
//  MyNewsTableViewCell.swift
//  vk
//
//  Created by Alexandr Evtodiy on 01.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit

class MyNewsTableViewCell: UITableViewCell {
    
    // отступы текста контента от левого и правого края
    private var indent: CGFloat = 5
    // задание максимальной высоты текста контента
    private var maxSizeTextContent: CGFloat = 200
    // высота ячейки
    private var defaultHeightButton: CGFloat = 10
    // переменную приходящую из контроллера заносим в область видимости объекта ячейки
    private var new: VkApiNewItem?
    // создаем замыкание для того чтобы обратится за перестройкой строки из контроллера
    var tap: ((_ new: VkApiNewItem) -> Void)?

    @IBOutlet weak var heightContentConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentConstrait: NSLayoutConstraint!
    @IBOutlet weak var heightButtonShowMoreLess: NSLayoutConstraint!
    @IBOutlet weak var bottomFirstButtonShowMoreLess: NSLayoutConstraint!
    @IBOutlet weak var bottomSecondButtonShowMoreLess: NSLayoutConstraint!
    
    @IBOutlet weak var buttonShowTextMoreLess: UIButton!
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
    
    @IBAction func buttonTextMoreLessTouchUpInside(_ sender: Any) {
        if let new = new {
            tap? (new)
        }
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
    
    func getLabelTextSize(text: String, font: UIFont) -> CGSize {
        // определяем максимальную ширину текста - это ширина ячейки минус отступы слева и справа
        let maxWidth = bounds.width - indent * 2
        // получаем размеры блока под надпись
        // используем максимальную ширину и максимально возможную высоту
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        // получаем прямоугольник под текст в этом блоке и уточняем шрифт
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        // получаем ширину блока, переводим её в Double
        let width = Double(rect.size.width)
        // получаем высоту блока, переводим её в Double
        let height = Double(rect.size.height)
        // получаем размер, при этом округляем значения до большего целого числа
        let size = CGSize(width: ceil(width), height: ceil(height))
        return size
    }
    
    func config (new: VkApiNewItem, photoService: PhotoService?, indexPath: IndexPath) {
        
        self.new = new
        
        if let avatarImageURL = new.avatarImageURL {
            avatarMyFriendNews.image = photoService?.photo(atIndexpath: indexPath, byUrl: avatarImageURL)
        }
        nameMyFriendNews.text = new.nameGroupOrUser
        let dateSince1970 = Date(timeIntervalSince1970: TimeInterval(new.date))
        date.text = dateFormatter.string(from: dateSince1970)
        
        if let text = self.new?.text {
            let sizeTextContent = getLabelTextSize(text: text, font: contentLabelNews.font)
            
            if sizeTextContent.height > maxSizeTextContent {
                heightButtonShowMoreLess.constant = defaultHeightButton
                if let isExpanded = self.new?.isExpanded,
                   !isExpanded {
                    heightContentConstraint.constant = maxSizeTextContent
                    buttonShowTextMoreLess.setTitle("show more", for: .normal)
                } else {
                    heightContentConstraint.constant = sizeTextContent.height
                    buttonShowTextMoreLess.setTitle("show less", for: .normal)
                }
            }
            else {
                buttonShowTextMoreLess.setTitle("", for: .normal)
                heightButtonShowMoreLess.constant = 0
                bottomFirstButtonShowMoreLess.constant = 0
                bottomSecondButtonShowMoreLess.constant = 0
                
                heightContentConstraint.constant = sizeTextContent.height
            }
        }
        else {
            buttonShowTextMoreLess.setTitle("", for: .normal)
            heightButtonShowMoreLess.constant = 0
            bottomFirstButtonShowMoreLess.constant = 0
            bottomSecondButtonShowMoreLess.constant = 0
            
            heightContentConstraint.constant = 0
            bottomContentConstrait.constant = 0
            
        }
        
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
