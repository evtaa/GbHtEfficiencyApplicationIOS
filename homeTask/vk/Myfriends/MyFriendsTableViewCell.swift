//
//  MyFriendsTableViewCell.swift
//  vk
//
//  Created by Alexandr Evtodiy on 06.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit

class MyFriendsTableViewCell: UITableViewCell {
    
    let indent: CGFloat = 10.0
    let avatarSideLenght: CGFloat = 80.0
    
    @IBOutlet weak var avatarView: AvatarCompositeView! {
        didSet {
            avatarView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var userName: UILabel! {
        didSet {
            userName.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setUserName(text: String) {
        userName.text = text
        userNameLabelFrame ()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarViewFrame()
        buttonFrame()
        userNameLabelFrame ()
    }
    
    func getLabelSize(text: String, font: UIFont) -> CGSize {
        //определяем максимальную ширину, которую может занимать наш текст
        //это ширина ячейки минус отступы слева и справа
        let maxWidth = bounds.width - indent * 2 - avatarView.bounds.width - 35
        //получаем размеры блока, в который надо вписать надпись
        //используем максимальную ширину и максимально возможную высоту
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        //получим прямоугольник, который займёт наш текст в этом блоке, уточняем, каким шрифтом он будет написан
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        //получаем ширину блока, переводим ее в Double
        let width = Double(rect.size.width)
        //получаем высоту блока, переводим ее в Double
        let height = Double(rect.size.height)
        //получаем размер, при этом округляем значения до большего целого числа
        let size = CGSize(width: ceil(width), height: ceil(height))
        return size
    }
    
    func userNameLabelFrame() {
        //получаем размер текста, передавая сам текст и шрифт.
        let userNameLabelSize = getLabelSize(text: userName.text!, font: userName.font)
        //рассчитывает координату по оси Х
        let userNameLabelX = bounds.width - userNameLabelSize.width - indent  //- 35 - avatarView.bounds.width
        //let userNameLabelX = indent + avatarView.bounds.width
        //рассчитывает координату по оси Y
        let userNameLabelY: CGFloat = 60
        //let userNameLabelY = bounds.height - indent - (avatarView.bounds.height + userNameLabelSize.height)/2 + 40
        //получим точку верхнего левого угла надписи
        let userNameLabelOrigin = CGPoint(x:  userNameLabelX, y: userNameLabelY)
        //получаем фрейм и устанавливаем UILabel
        userName.frame = CGRect(origin: userNameLabelOrigin, size: userNameLabelSize)
    }
    
    func avatarViewFrame() {
        let avatarSize = CGSize(width: avatarSideLenght, height: avatarSideLenght)
        let avatarOrigin = CGPoint(x: indent, y: indent)
        avatarView.frame = CGRect(origin: avatarOrigin, size: avatarSize)
    }
    
    func buttonFrame() {
        let buttonSize = CGSize(width: avatarSideLenght, height: avatarSideLenght)
        let buttonOrigin = CGPoint(x: indent, y: indent)
        button.frame = CGRect(origin: buttonOrigin, size: buttonSize)
    }
    
    // MARK: Configure Cell
    
    func config (user: VkApiUsersItem, photoService: PhotoService?, indexPath: IndexPath) {
        if let avatarPhotoURL = user.avatarPhotoURL {
            avatarView.avatarPhoto.image = photoService?.photo(atIndexpath: indexPath, byUrl: avatarPhotoURL)
        }
        setUserName(text: user.lastName + " " + user.firstName)
        avatarView.setup()
    }
    
    // MARK: Animation
    
    @IBAction func downButtonTouchDown(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.avatarView.avatarShadow.bounds.size.height -= 10
                        self.avatarView.avatarShadow.bounds.size.width -= 10
                        self.avatarView.avatarShadow.layer.cornerRadius -=  5
                        
                        self.avatarView.avatarPhoto.bounds.size.height -= 10
                        self.avatarView.avatarPhoto.bounds.size.width -= 10
                        self.avatarView.avatarPhoto.layer.cornerRadius -=  5
                       })
    }
    
    @IBAction func upButtonTouchUpInside(_ sender: Any) {
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 2,
                       options: [],
                       animations: {
                        self.avatarView.avatarShadow.bounds.size.height += 10
                        self.avatarView.avatarShadow.bounds.size.width += 10
                        self.avatarView.avatarShadow.layer.cornerRadius +=  5
                        
                        self.avatarView.avatarPhoto.bounds.size.height += 10
                        self.avatarView.avatarPhoto.bounds.size.width += 10
                        self.avatarView.avatarPhoto.layer.cornerRadius +=  5
                       })
    }
    
    @IBAction func upButtonTouchUpOutside(_ sender: UIButton) {
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 2,
                       options: [],
                       animations: {
                        self.avatarView.avatarShadow.bounds.size.height += 10
                        self.avatarView.avatarShadow.bounds.size.width += 10
                        self.avatarView.avatarShadow.layer.cornerRadius +=  5
                        
                        self.avatarView.avatarPhoto.bounds.size.height += 10
                        self.avatarView.avatarPhoto.bounds.size.width += 10
                        self.avatarView.avatarPhoto.layer.cornerRadius +=  5
                       })
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
