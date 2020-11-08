//
//  SaveDataToRealm.swift
//  vk
//
//  Created by Alexandr Evtodiy on 08.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation

class SaveDataToRealm: Operation {
    
    var realmSaveService = RealmSaveService ()
    
    override func main() {
        guard let parseData = dependencies.first as? ParseData,
              let items = parseData.VkApiGroupsResponseItems else { return }
        // Save group array to Database
        // Working with Realm
        self.realmSaveService.updateGroups(groups: items)
        // Working with Firebase
        //self?.firebaseSaveService.updateGroups(groups: VkApiGroupsResponseItems)
    }
}
