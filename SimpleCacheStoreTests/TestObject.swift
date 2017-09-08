//
//  TestObject.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 31.01.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import Foundation
import UIKit

class TestObject: NSObject, NSCoding {
    var name: String?
    var status: String?
    var image: UIImage?
    
    init(name: String, status: String, image: UIImage) {
        self.name = name
        self.status = status
        self.image = image
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: "name") as? String, let status = aDecoder.decodeObject(forKey: "status") as? String, let image = aDecoder.decodeObject(forKey: "image") as? UIImage else {
            return nil
        }
        self.init(name: name, status: status, image: image)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.status, forKey: "status")
        aCoder.encode(self.image, forKey: "image")
    }
}
