//
//  MyCommunitiesTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 07.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class MyCommunitiesTableViewController: UITableViewController {
    
    internal let newRefreshControl = UIRefreshControl()
    var myGroups = [FirebaseGroup] ()
    let vkService = VKService ()

        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView ()
        setupRefreshControl ()
        
        //отправим запрос для получения  групп пользователя
        fetchGroupsData()
        notificationChangingGroupsInFirebase ()
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
        self.newRefreshControl.endRefreshing()
    }
    
    private func fetchGroupsData () {
        
        vkService.loadGroupsData(userId: Session.instance.userId!)
    }
    
    private func notificationChangingGroupsInFirebase () {
        //создаем наблюдатель изменений в ветке refBranchUsers
        vkService.firebaseSaveService.refBranchGroups.observe(.value, with: { [weak self] snapshot in
            var groups: [FirebaseGroup] = []
            for child in snapshot.children {
                        if let snapshot = child as? DataSnapshot,
                           let group = FirebaseGroup(snapshot: snapshot) {
                               groups.append(group)
                        }
                    }
            self?.myGroups = groups
            self?.tableView.reloadData()
            self?.newRefreshControl.endRefreshing()
        })
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        let count  = self.myGroups.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommunitiesCell", for: indexPath) as! MyCommunitiesTableViewCell
        
        let numberOfRows = self.tableView.numberOfRows(inSection: 0)
        guard indexPath.row <= numberOfRows else {return cell}
        let myGroup  = self.myGroups [indexPath.row]
        cell.setup(group: myGroup)
        return cell
    }
    
     //Override to support editing the table view.
    
    // Здесь нужно вызвать запрос серверу на удаление из группы
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let group = myGroups [indexPath.row]
            group.ref?.removeValue()
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
