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
        case snapshot
    }
    
    let coreDataManger: SCCoreDataManager?
    let cacheManager: SCCacheManager?
    //let operationQueue: NSOperationQueue
        
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
        if(SCGlobalOptions.Options.cacheMode == .snapshot) {
            cacheWalker.restoreSnapshot()
        } else {
            cacheWalker.establishCacheFromPersistentObjects({ success in })
        }
        cacheManager = SCCacheManager.sharedInstance
        
        //operationQueue = NSOperationQueue()
    }
    
    deinit {
        if SCGlobalOptions.Options.cacheMode == .snapshot {
            self.takeSnapshot()
        }
    }

    fileprivate func save(_ forKey: String, object: NSObject, answer: @escaping (Bool, String) -> ()) {
        if let cdm = coreDataManger {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
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
    
    open func save(_ forKey: String, object: NSObject) -> Bool {
        if let cdm = coreDataManger {
            if cdm.saveObject(forKey: forKey, object: object) {
                if let cam = self.cacheManager {
                    cam.saveObjectToCache(forKey, object: object)
                    print("[SCManager:save] -> Objekt in NSCache gelegt")
                }
                return true
            }
        }
        return false
    }
    
    open func save(forKey: String, object: NSObject, label: String) -> Bool {
        if let cdm = coreDataManger {
            if cdm.saveObject(forKey: forKey, object: object, label: label) {
                if let cam = self.cacheManager {
                    cam.saveObjectToCache(forKey, object: object)
                    print("[SCManager:save] -> Objekt in NSCache gelegt")
                }
                return true
            }
        }
        return false
    }
    
    open func get(_ forKey: String, answer: @escaping (Bool, NSObject?) -> ()) {
        if let cam = cacheManager {
            if let cachedObj = cam.getObjectFromCache(forKey) {
                print("[SCManager:get] -> Objekt aus NSCache geladen")
                answer(true, cachedObj)
            } else {
                if let cdm = coreDataManger {
                    /*self.operationQueue.addOperationWithBlock({
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
                    })*/
                    SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
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
                /*self.operationQueue.addOperationWithBlock({
                    cdm.getObject(forKey, answer: {
                        success, data in
                        print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
                        answer(success, data)
                    })
                })*/
                SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
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
    
    open func get(_ forKey: String) -> NSObject? {
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
    
    open func get(byLabel: String, answer: @escaping (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            /*self.operationQueue.addOperationWithBlock({
             cdm.getObject(forKey, answer: {
             success, data in
             print("[SCManager:get] -> Objekt nicht in NSCache, deshalb aus CoreData")
             answer(success, data)
             })
             })*/
            SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
                cdm.getObjects(byLabel: byLabel, answer: {
                    success, data in
                    //Enable Entry in NSCache
                    print("[SCManager:get] -> Objekte nicht in NSCache, deshalb aus CoreData")
                    answer(success, data)
                })
            })
        }
    }
    
    open func get(byLabel: String) -> [NSObject]? {
        if let cdm = coreDataManger {
            return cdm.getObjects(byLabel: byLabel)
        }
        return nil
    }
    
    open func delete(_ forKey: String) -> Bool {
        var answer = false
        if let cdm = coreDataManger {
            if cdm.deleteObject(forKey) {
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
    
    open func getAll(_ answer: @escaping (Bool, [NSObject]?) -> ()) {
        if let cdm = coreDataManger {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                cdm.getAllObjects({
                    success, data in
                    print("[SCManager:getAll] -> Objekte aus CoreData")
                    answer(success, data)
                })
            })
        }
    }
    
    open func takeSnapshot() {
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
    
    fileprivate func periodicSnapshot() {
        let cacheWalker = SCCacheWalker()
        cacheWalker.saveSnapshot()
    }
}
