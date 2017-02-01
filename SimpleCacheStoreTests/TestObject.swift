//
//  TestObject.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 31.01.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import Foundation

class TestObject: NSObject, NSCoding {
    var name: String?
    var status: String?
    
    init(name: String, status: String) {
        self.name = name
        self.status = status
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String, let status = aDecoder.decodeObject(forKey: "status") as? String else {
            return nil
        }
        self.init(name: name, status: status)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.status, forKey: "status")
    }
}
