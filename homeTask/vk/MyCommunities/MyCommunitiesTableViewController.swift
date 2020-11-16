//
//  MyCommunitiesTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 07.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import RealmSwift

class MyCommunitiesTableViewController: UITableViewController {
    
    internal let newRefreshControl = UIRefreshControl()
    var myGroups: [VkApiGroupItem]?
    let vkService = VKService ()
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView ()
        setupRefreshControl ()
        // отправим запрос для получения  групп пользователя
        fetchGroupsData()
        pairTableAndRealm { [weak self] myGroups in
            guard let tableView = self?.tableView else { return }
            self?.myGroups = myGroups
            tableView.reloadData()
 //           self?.newRefreshControl.endRefreshing()
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
        newRefreshControl.addTarget(self, action: #selector(refreshGroupsData(_:)), for: .valueChanged)
        newRefreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 0.7)
    }
    
    @objc func refreshGroupsData(_ sender: Any) {
        
        fetchGroupsData ()
    }
    
    private func fetchGroupsData () {
        if let userID = Session.instance.userId {
            vkService.loadGroupsData(userId: userID)
            self.newRefreshControl.endRefreshing()
        }
    }
    
    func pairTableAndRealm(completion: @escaping  ([VkApiGroupItem]) -> Void ) {
            guard let realm = try? Realm() else { return }
        let objects = realm.objects(VkApiGroupItem.self)
        token = objects.observe { (changes: RealmCollectionChange) in
                switch changes {
                case .initial (let results):
                    guard !results.isInvalidated else {return}
                    //let myGroups = [VkApiGroupItem](results)
                    let myGroups:[VkApiGroupItem] = self.transRealmAnswerToArray(answer: results)
                    debugPrint(".initial : \(myGroups.count) myFriends loaded from DB")
                    completion(myGroups)
                case .update (let results, _, _, _):
                    guard !results.isInvalidated else {return}
                    //let myGroups = [VkApiGroupItem](results)
                    let myGroups:[VkApiGroupItem] = self.transRealmAnswerToArray(answer: results)
                    debugPrint(".initial : \(myGroups.count) myFriends loaded from DB")
                    completion(myGroups)
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        }

    private func transRealmAnswerToArray (answer: Results<VkApiGroupItem>) -> [VkApiGroupItem]  {
        var array:[VkApiGroupItem] = [VkApiGroupItem] ()
        for object in answer {
            let group: VkApiGroupItem = VkApiGroupItem ()
            group.id = Int(object.id)
            group.name = object.name
            group.screenName = object.screenName
            group.photoSmallURL =  object.photoSmallURL
            group.photoMediumURL =  object.photoMediumURL
            group.photoLargeURL =  object.photoLargeURL
            array.append(group)
        }
        return array
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        guard let count  = self.myGroups?.count else {
                    return 0
                }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommunitiesCell", for: indexPath) as! MyCommunitiesTableViewCell
        
        guard let myGroup  = self.myGroups? [indexPath.row] else { return cell }
        cell.setup(group: myGroup, tableView: self.tableView, indexPath: indexPath)
        return cell
    }
    
     //Override to support editing the table view.
    
    // Здесь нужно вызвать запрос серверу на удаление из группы
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let group = myGroups? [indexPath.row]  else { return }
            vkService.realmSaveService.deleteGroup(group: group)
        }
    }

    // MARK: -Segue
    //Здесь нужно вызвать запрос серверу на добавление группы
//    @IBAction func addCommunity (segue: UIStoryboardSegue) {
//        if segue.identifier == "addCommunity" {
//            let allCommunitiesTableViewController = segue.source as! AllCommunitiesTableViewController
//            if let indexPath = allCommunitiesTableViewController.tableView.indexPathForSelectedRow {
//                let community = allCommunitiesTableViewController.allCommunities [indexPath.row]
//                if !myCommunities.contains(where: {myCommunity -> Bool in
//                    return community == myCommunity
//                }) {
//                    myCommunities.append(community)
//                    tableView.reloadData()
//                }
//            }
//        }
//    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
