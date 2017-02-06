//
//  SCCacheWalker.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 23.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class SCCacheWalker {
    
    let cm: SCCacheManager
    
    init() {
        cm = SCCacheManager.sharedInstance
        
    }
    
    func establishCacheFromPersistentObjects(_ answer: @escaping (Bool) -> ()) {
        let cdm = SCCoreDataManager()
        SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
            cdm.getObjectDump(answer: {
                objectDict in
                if let persistentObjects = objectDict {
                    self.cm.setCache(persistentObjects)
                    answer(true)
                }
            })
        })
    }
    
}
