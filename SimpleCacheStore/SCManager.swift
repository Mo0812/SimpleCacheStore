//
//  SCManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

open class SCManager {
        
    public enum CacheMode {
        case rebuild
    }
    
    let coreDataManger: SCCoreDataManager?
    let cacheManager: SCCacheManager?
        
    public convenience init() {
        self.init(cacheMode: .rebuild)
    }
    
    public convenience init(cacheMode: CacheMode, cacheLimit: Int) {
        SCGlobalOptions.Options.cacheLimit = cacheLimit
        self.init(cacheMode: cacheMode)
    }
    
    public init(cacheMode: CacheMode) {
        SCGlobalOptions.Options.cacheMode = cacheMode

        coreDataManger = SCCoreDataManager()
        
        let cacheWalker = SCCacheWalker()
        cacheWalker.establishCacheFromPersistentObjects({ success in })
        
        cacheManager = SCCacheManager.sharedInstance
        
    }
    
    deinit {
        
    }
    
    open func save(forKey: String, object: NSObject) {
        self.save(forKey: forKey, object: object, label: SCGlobalOptions.Options.defaultLabel)
    }
    
    open func save(forKey: String, object: NSObject, label: String) {
        if let cdm = coreDataManger {
            SCGlobalOptions.Options.concurrentSCSQueue.sync(execute: {
                cdm.saveObject(forKey: forKey, object: object, label: label)
                if let cam = self.cacheManager {
                    cam.saveObjectToCache(forKey, object: object)
                    print("[SCManager:save] -> Objekt in NSCache gelegt")
                }
            })
        }
    }
    
    open func get(forKey: String, answer: @escaping (Bool, NSObject?) -> ()) {
        if let cam = cacheManager {
            if let cachedObj = cam.getObjectFromCache(forKey) {
                print("[SCManager:get] -> Objekt aus NSCache geladen")
                answer(true, cachedObj)
            } else {
                if let cdm = coreDataManger {
                    SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
                        cdm.getObject(forKey: forKey, answer: {
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
                SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
                    cdm.getObject(forKey: forKey, answer: {
                        success, data in
                        //Enable Entry in NSCache
                        print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
                        answer(success, data)
                    })
                })
            }
        }
    }
    
    open func get(byLabel: String, answer: @escaping (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
                cdm.getObjects(byLabel: byLabel, answer: {
                    success, data in
                    //Enable Entry in NSCache
                    answer(success, data)
                })
            })
        }
    }
    
    open func delete(forKey: String) -> Bool {
        var answer = false
        if let cdm = coreDataManger {
            if cdm.deleteObject(forKey: forKey) {
                answer = true
            }
        }
        if let cam = cacheManager {
            cam.deletObjectFromCache(forKey)
        }
        return answer
    }
    
    open func clear()  -> Bool{
        if let cdm = coreDataManger {
            if cdm.clearCache() {
                if let cam = cacheManager {
                    cam.clearTotalCache()
                }
                return true
            }
        }
        return false
    }
    
    open func getAll(answer: @escaping (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                cdm.getAllObjects(answer: {
                    success, data in
                    print("[SCManager:getAll] -> Objekte aus CoreData")
                    answer(success, data)
                })
            })
        }
    }
    
}
