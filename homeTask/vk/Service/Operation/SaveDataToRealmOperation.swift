//
//  SaveDataToRealm.swift
//  vk
//
//  Created by Alexandr Evtodiy on 08.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation

class SaveDataToRealmOperation: Operation {
    
    var realmSaveService = RealmSaveService ()
    
    override func main() {
        guard let parseData = dependencies.first as? ParseDataOperation,
              let items = parseData.VkApiGroupsResponseItems else { return }
        // Save group array to Database
        // Working with Realm
        self.realmSaveService.updateGroups(groups: items)
        // Working with Firebase
        //self?.firebaseSaveService.updateGroups(groups: VkApiGroupsResponseItems)
    }
}
