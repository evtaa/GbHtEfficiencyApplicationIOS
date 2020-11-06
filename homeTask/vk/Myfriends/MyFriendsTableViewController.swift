//
//  MyFriendsTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 06.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import FirebaseDatabase

class MyFriendsTableViewController: UITableViewController {
    
    internal let newRefreshControl = UIRefreshControl()
    
    var myFriendsDictionary: [String: [VkApiUsersItem]] = [:]
    var myFriendNameSectionTitles: [String] = []
    var myFriends: [VkApiUsersItem]?
    let vkService = VKService()
    var token: NotificationToken?
    var usersOfApplication = [FirebaseUser] ()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView ()
        setupRefreshControl ()
        // отправим запрос для получения  списка друзей
        vkService.firebaseSaveService.saveCurrentUserApplication(id: Session.instance.userId!)
        notificationChangingUsersInFirebase ()
        fetchFriendsData ()
        pairTableAndRealm { [weak self] myFriends in
            guard let tableView = self?.tableView else { return }
            self?.myFriends = myFriends
            let searchWord = self?.searchBar.text
            self?.setDictionaryAndSectionTitlesOfMyFriends(searchText: searchWord ?? "")
            tableView.reloadData()
            self?.newRefreshControl.endRefreshing()
        }
    }
    
    private func setupTableView () {
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = newRefreshControl
        } else {
            tableView.addSubview(newRefreshControl)
        }
        
        // Убираем разделительные линии между пустыми ячейками
        tableView.tableFooterView = UIView ()
    }
    
    private func setupRefreshControl () {
        // Configure Refresh Control
        newRefreshControl.addTarget(self, action: #selector(refreshFriendsData(_:)), for: .valueChanged)
        newRefreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 0.7)
    }
    
    @objc func refreshFriendsData(_ sender: Any) {
        fetchFriendsData ()
    }
    
    private func fetchFriendsData () {
        DispatchQueue.global().async { [weak self] in
            self?.vkService.loadFriendsData(userId: String(Session.instance.userId!))
        }
    }
    
    // Функция уведомлений о изменениях в списке пользователей приложением
    private func notificationChangingUsersInFirebase () {
        //создаем наблюдатель изменений в ветке refBranchUsers
        vkService.firebaseSaveService.refBranchUsers.observe(.value, with: { snapshot in
            var users: [FirebaseUser] = []
            for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                           let user = FirebaseUser(snapshot: snapshot) {
                               users.append(user)
                        }
                    }
            self.usersOfApplication = users
        })
        
    }
    
    func pairTableAndRealm(completion: @escaping  ([VkApiUsersItem]) -> Void ) {
        guard let realm = try? Realm() else { return }
        let objects = realm.objects(VkApiUsersItem.self)
        token = objects.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial (let results):
                guard !results.isInvalidated else {return}
                //let myFriends = [VkApiUsersItem](results)
                let myFriends = self.transRealmAnswerToArray (answer: results)
                debugPrint(".initial : \(myFriends.count) myFriends loaded from DB")
                completion(myFriends)
            case .update(let results, _, _, _):
                guard !results.isInvalidated else {return}
                //let myFriends = [VkApiUsersItem](results)
                let myFriends = self.transRealmAnswerToArray (answer: results)
                debugPrint(".update : \(myFriends.count) myFriends loaded from DB")
                completion(myFriends)
            case .error(let error):
                debugPrint(".error")
                debugPrint(error)
            }
        }
    }
    
    private func transRealmAnswerToArray (answer: Results<VkApiUsersItem>) -> [VkApiUsersItem]  {
        var array:[VkApiUsersItem] = [VkApiUsersItem] ()
        for object in answer {
            let friend: VkApiUsersItem = VkApiUsersItem ()
            friend.id = Int(object.id)
            friend.firstName = object.firstName
            friend.lastName = object.lastName
            friend.cityTitle =  object.cityTitle
            friend.avatarPhotoURL =  object.avatarPhotoURL
            array.append(friend)
        }
        return array
    }
    
    func setDictionaryAndSectionTitlesOfMyFriends (searchText: String ) {
        // Формирование словаря друзей ключ: [друг]  и массива ключей
        myFriendsDictionary = [:]
        myFriendNameSectionTitles = []
        guard let myFriends = myFriends else {return}
        for myFriend in myFriends {
            let name = myFriend.lastName
            if (name.starts(with: searchText) == false) {
                continue
            }
            let myFriendNameKey = String (name.prefix(1))
            if myFriendsDictionary [myFriendNameKey] == nil {
                myFriendsDictionary [myFriendNameKey] = []
            }
            myFriendsDictionary[myFriendNameKey]?.append(myFriend)
        }
        myFriendNameSectionTitles = myFriendsDictionary.keys.sorted()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return myFriendNameSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let myFriendNameKey = myFriendNameSectionTitles [section]
        if let myFriendValues = myFriendsDictionary [myFriendNameKey] {
            return myFriendValues.count
        }
        return 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Вытащим ячейку из пула
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendCell", for: indexPath) as! MyFriendsTableViewCell
        
        let myFriendNameKey = myFriendNameSectionTitles [indexPath.section]
        if let myFriendValue = myFriendsDictionary [myFriendNameKey] {
            let user = myFriendValue [indexPath.row]
            cell.setup(user: user)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return myFriendNameSectionTitles [section]
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return myFriendNameSectionTitles
    }
    
    // MARK: Delete table's row
    // Здесь нужно вызвать запрос серверу на удаление из группы
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let myFriendNameKey = myFriendNameSectionTitles [indexPath.section]
            if let myFriendValue = myFriendsDictionary [myFriendNameKey] {
                let user = myFriendValue [indexPath.row]
                vkService.realmSaveService.deleteUser(user: user)
            }
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверяем идентификатор чтобы убедиться, что это нужный переход
        if segue.identifier == "getSelectedFriend" {
            // Создаем указатель контроллера на который будет осуществлен переход
            let photosMyFriendCollectionViewController = segue.destination as? PhotosMyFriendCollectionViewController
            // Получаем индекс выделенной ячейки таблицы
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // Передаем экземпляр объекта класса User контроллеру на который будет осуществлен переход
                
                let myFriendNameKey = myFriendNameSectionTitles [indexPath.section]
                if let myFriendValue = myFriendsDictionary [myFriendNameKey] {
                    let friend = myFriendValue[indexPath.row]
                    photosMyFriendCollectionViewController?.friendSelected = friend
                }
            }
        }
        
    }
}

extension MyFriendsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        setDictionaryAndSectionTitlesOfMyFriends(searchText: searchText)
        tableView.reloadData()
    }
}
