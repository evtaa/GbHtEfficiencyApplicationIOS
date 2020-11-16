//
//  ParseData.swift
//  vk
//
//  Created by Alexandr Evtodiy on 08.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation

class ParseDataOperation: Operation {
    
    var VkApiGroupsResponseItems: [VkApiGroupItem]? = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
              let data = getDataOperation.data else { return }
        do {
            let  vkApiGroupResponse = try JSONDecoder().decode (VkApiGroupResponse.self, from: data)
            VkApiGroupsResponseItems = vkApiGroupResponse.response.items
            debugPrint (data)
        }
        catch DecodingError.dataCorrupted(let context) {
            debugPrint(DecodingError.dataCorrupted(context))
        }
        catch let error {
            debugPrint(error)
            debugPrint(String(bytes: data, encoding: .utf8) ?? "")
        }
    }
}
