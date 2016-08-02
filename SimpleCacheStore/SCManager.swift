//
//  SCManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

public class SCManager {
    
    public enum CacheMode {
        case Rebuild
        case Snapshot
    }
    
    let coreDataManger: SCCoreDataManager?
    let cacheManager: SCCacheManager?
        
    public convenience init() {
        self.init(cacheMode: .Rebuild)
    }
    
    public convenience init(cacheMode: CacheMode, cacheLimit: Int) {
        SCGlobalOptions.Options.cacheLimit = cacheLimit
        self.init(cacheMode: cacheMode)
    }
    
    public init(cacheMode: CacheMode) {
        SCGlobalOptions.Options.cacheMode = cacheMode

        coreDataManger = SCCoreDataManager()
        
        let cacheWalker = SCCacheWalker()
        if(SCGlobalOptions.Options.cacheMode == .Snapshot) {
            cacheWalker.restoreSnapshot()
        } else {
            cacheWalker.establishCacheFromPersistentObjects({ success in })
        }
        cacheManager = SCCacheManager.sharedInstance
    }
    
    deinit {
        if SCGlobalOptions.Options.cacheMode == .Snapshot {
            self.takeSnapshot()
        }
    }

    private func save(forKey: String, object: NSObject, answer: (Bool, String) -> ()) {
        if let cdm = coreDataManger {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                cdm.saveObject(forKey, object: object, answer: {
                    success, message in
                    
                    if let cam = self.cacheManager {
                        cam.saveObjectToCache(forKey, object: object)
                        print("[SCManager:save] -> Objekt in NSCache gelegt")
                    }
                    
                    answer(success, message)
                })
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
                    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
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
                    })
                }
            }
        } else {
            if let cdm = coreDataManger {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                    cdm.getObject(forKey, answer: {
                        success, data in
                        //Enable Entry in NSCache
                        print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
                        answer(success, data)
                    })
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
            if let cam = cacheManager {
                cam.clearTotalCache()
            }
            answer(true)
        }
    }
    
    public func getAll(answer: (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
                cdm.getAllObjects({
                    success, data in
                    print("[SCManager:getAll] -> Objekte aus CoreData")
                    answer(success, data)
                })
            })
        }
    }
    
    public func takeSnapshot() {
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
    
    private func periodicSnapshot() {
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
}