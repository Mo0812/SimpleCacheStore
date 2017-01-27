//
//  SCCacheManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

class SCCacheManager {
    
    static let sharedInstance = SCCacheManager(limit: SCGlobalOptions.Options.cacheLimit)
    fileprivate var cache: NSCache<AnyObject, AnyObject>
    fileprivate var cacheDictionary: Dictionary<String, NSObject>
    
    init(limit: Int) {
        cache = NSCache()
        cache.countLimit = limit
        cacheDictionary = [String: NSObject]()
    }
    
    func saveObjectToCache(_ forKey: String, object: NSObject) {
        if cache.object(forKey: forKey as AnyObject) != nil {
            cache.removeObject(forKey: forKey as AnyObject)
        }
        cache.setObject(object, forKey: forKey as AnyObject)
        //Snapshot Mode
        if SCGlobalOptions.Options.cacheMode == SCManager.CacheMode.snapshot {
            if cacheDictionary[forKey] != nil {
                cacheDictionary.updateValue(object, forKey: forKey)
            } else {
                cacheDictionary[forKey] = object
            }
        }
    }
    
    func getObjectFromCache(_ forKey: String) -> NSObject? {
        if let cachedVersion = cache.object(forKey: forKey as AnyObject) as? NSObject {
            return cachedVersion
        } else {
            return nil
        }
    }
    
    func deletObjectFromCache(_ forKey: String) {
        cache.removeObject(forKey: forKey as AnyObject)
        if SCGlobalOptions.Options.cacheMode == SCManager.CacheMode.snapshot {
            cacheDictionary[forKey] = nil
        }
    }
    
    func clearTotalCache() {
        cache.removeAllObjects()
    }
    
    func getCacheDictionary() -> Dictionary<String, NSObject> {
        return cacheDictionary
    }
    
    func setCache(_ cache: Dictionary<String, NSObject>) {
        cache.map({key, value in self.saveObjectToCache(key, object: value)})
        print("SET CACHE FOR REAL")
    }
    
}
