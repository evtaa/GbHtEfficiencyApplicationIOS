//
//  AllCommunitiesTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 07.08.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit

class AllCommunitiesTableViewController: UITableViewController {
    
    var searchGroups: [VkApiGroupItem]?
    let vkService = VKService ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchGroups = [VkApiGroupItem]()
        self.tableView.reloadData()
        
        // Убираем разделительные линии между пустыми ячейками
        tableView.tableFooterView = UIView ()
        
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let count  = self.searchGroups?.count else {
                    return 0
                }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllCommunitiesCell", for: indexPath) as! AllCommunitiesTableViewCell
       
        guard let searchGroup  = self.searchGroups?[indexPath.row] else {
                    return cell
                }
        cell.setup(group: searchGroup)
        
        return cell
        
    }
}

extension AllCommunitiesTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            self.searchGroups = [VkApiGroupItem]()
        }
        else {
            vkService.loadSearchGroupsData(search: searchText) { [weak self] searchGroups in
                // сохраняем полученные данные в массиве
                self?.searchGroups = searchGroups
            }
        }
        self.tableView.reloadData()
    }
}
