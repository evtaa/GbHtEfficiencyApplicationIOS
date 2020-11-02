//
//  SessionSingleton.swift
//  vk
//
//  Created by Alexandr Evtodiy on 20.09.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation

class Session {
    private init() {}
    
    static let instance = Session ()
    
    var token: String?
    var userId: Int?
    
}
