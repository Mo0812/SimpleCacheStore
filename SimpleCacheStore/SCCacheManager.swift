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
    private var cache: NSCache
    private var cacheDictionary: Dictionary<String, NSObject>
    
    init(limit: Int) {
        cache = NSCache()
        cache.countLimit = limit
        cacheDictionary = [String: NSObject]()
    }
    
    func saveObjectToCache(forKey: String, object: NSObject) {
        if cache.objectForKey(forKey) != nil {
            cache.removeObjectForKey(forKey)
        }
        cache.setObject(object, forKey: forKey)
        //Snapshot Mode
        if SCGlobalOptions.Options.cacheMode == SCManager.CacheMode.Snapshot {
            if cacheDictionary[forKey] != nil {
                cacheDictionary.updateValue(object, forKey: forKey)
            } else {
                cacheDictionary[forKey] = object
            }
        }
    }
    
    func getObjectFromCache(forKey: String) -> NSObject? {
        if let cachedVersion = cache.objectForKey(forKey) as? NSObject {
            return cachedVersion
        } else {
            return nil
        }
    }
    
    func deletObjectFromCache(forKey: String) {
        cache.removeObjectForKey(forKey)
        if SCGlobalOptions.Options.cacheMode == SCManager.CacheMode.Snapshot {
            cacheDictionary[forKey] = nil
        }
    }
    
    func clearTotalCache() {
        cache.removeAllObjects()
    }
    
    func getCacheDictionary() -> Dictionary<String, NSObject> {
        return cacheDictionary
    }
    
    func setCache(cache: Dictionary<String, NSObject>) {
        cache.map({key, value in self.saveObjectToCache(key, object: value)})
        print("SET CACHE FOR REAL")
    }
    
}