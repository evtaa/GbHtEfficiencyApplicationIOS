//
//  GetDataOperation.swift
//  vk
//
//  Created by Alexandr Evtodiy on 08.11.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import Foundation
import Alamofire

class GetDataOperation: AsyncOperation {
    
    override func cancel() {
        request.cancel()
        super.cancel()
    }
    
    private var request: DataRequest
    var data: Data?
    
    override func main() {
        
        request.responseData { [weak self] response in
            switch response.result{
            case .success(let data):
                self?.data = data
                self?.state = .finished
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    init(request: DataRequest) {
        self.request = request
    }
}
