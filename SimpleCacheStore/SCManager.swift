//
//  SCManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

public class SCManager {
    
    let coreDataWalker: SCCoreDataWalker?
    let coreDataManger: SCCoreDataManager?
    let cacheManager: SCCacheManager?
    
    public convenience init() {
        self.init(expiringDate: NSDate())
    }
    
    public init(expiringDate: NSDate) {
        SCGlobalOptions.Options.expiringDate = expiringDate
        coreDataWalker = SCCoreDataWalker()
        //coreDataWalker?.cleanCache()
        coreDataManger = SCCoreDataManager()
        cacheManager = SCCacheManager()
    }
    
    public func save(forKey: String, object: NSObject, answer: (Bool, String) -> ()) {
        if let cdm = coreDataManger {
            cdm.saveObject(forKey, object: object, answer: {
                success, message in
                
                if let cam = self.cacheManager {
                    cam.saveObjectToCache(forKey, object: object)
                    print("[SCManager:save] -> Objekt in NSCache gelegt")
                }
                
                answer(success, message)
            })
        }
    }
    
    public func save(forKey: String, object: NSObject) -> Bool {
        if let cdm = coreDataManger {
            if cdm.saveObject(forKey, object: object) {
                if let cam = self.cacheManager {
                    cam.saveObjectToCache(forKey, object: object)
                    print("[SCManager:save] -> Objekt in NSCache gelegt")
                }
                return true
            }
        }
        return false
    }
    
    public func get(forKey: String, answer: (Bool, NSObject?) -> ()) {
        if let cam = cacheManager {
            if let cachedObj = cam.getObjectFromCache(forKey) {
                print("[SCManager:get] -> Objekt aus NSCache geladen")
                answer(true, cachedObj)
            } else {
                if let cdm = coreDataManger {
                    cdm.getObject(forKey, answer: {
                        success, data in
                        print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
                        answer(success, data)
                    })
                }
            }
        } else {
            if let cdm = coreDataManger {
                cdm.getObject(forKey, answer: {
                    success, data in
                    answer(success, data)
                })
            }
        }
    }
    
    public func get(forKey: String) -> NSObject? {
        if let cam = cacheManager {
            if let cacheObj = cam.getObjectFromCache(forKey) {
                print("[SCManager:get] -> Objekt aus NSCache geladen")
                return cacheObj
            } else {
                if let cdm = coreDataManger {
                    print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
                    return cdm.getObject(forKey)
                }
            }
        } else {
            if let cdm = coreDataManger {
                return cdm.getObject(forKey)
            }
        }
        return nil
    }
    
    public func delete(forKey: String, answer: (Bool) -> ()) {
        if let cdm = coreDataManger {
            cdm.deleteObject(forKey)
            answer(true)
        }
    }
    
    public func clear(answer: (Bool) -> ()) {
        if let cdm = coreDataManger {
            cdm.clearCache()
            answer(true)
        }
    }
    
    public func getAll(answer: (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            cdm.getAllObjects({
                success, data in
                print("[SCManager:getAll] -> Objekte aus CoreData")
                answer(success, data)
            })
        }
    }
    
}