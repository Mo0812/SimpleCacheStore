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
    
    public convenience init(expiringDate: NSDate, cacheLimit: Int) {
        SCGlobalOptions.Options.cacheLimit = cacheLimit
        self.init(expiringDate: expiringDate)
    }
    
    public init(expiringDate: NSDate) {
        SCGlobalOptions.Options.expiringDate = expiringDate
        
        coreDataWalker = SCCoreDataWalker()
        coreDataManger = SCCoreDataManager()
        
        let cacheWalker = SCCacheWalker()
        cacheWalker.restoreSnapshot()
        cacheManager = SCCacheManager.sharedInstance
        
        NSTimer(timeInterval: 2, target: self, selector: "periodicSnapshot", userInfo: nil, repeats: true)
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
                        //Enable Entry in NSCache
                        if let cdData = data {
                            cam.saveObjectToCache(forKey, object: cdData)
                            print("[SCManager:get] -> Objekt nach nicht auffinden gecacht")
                        }
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
                    let cdObject = cdm.getObject(forKey)
                    if let cdData = cdObject {
                        cam.saveObjectToCache(forKey, object: cdData)
                        print("[SCManager:get] -> Objekt nach nicht auffinden gecacht")
                    }
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
        if let cam = cacheManager {
            cam.deletObjectFromCache(forKey)
        }
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
    
    public func createSnapshot() {
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
    
    private func periodicSnapshot() {
        print("PERIODIC SNAPSHOT")
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
}