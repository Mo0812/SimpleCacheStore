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
        if let cachedVersion = cache.objectForKey(forKey) {
            cache.removeObjectForKey(forKey)
        }
        cache.setObject(object, forKey: forKey)
        //Dicitonary Code
        if let dictionaryVersion = cacheDictionary[forKey] {
            cacheDictionary.updateValue(object, forKey: forKey)
        } else {
            cacheDictionary[forKey] = object
        }
    }
    
    func getObjectFromCache(forKey: String) -> NSObject? {
        if let cachedVersion = cache.objectForKey(forKey) as? NSObject {
            return cachedVersion
        } else {
            return nil
        }
    }
    
    func getCacheDictionary() -> Dictionary<String, NSObject> {
        return cacheDictionary
    }
    
    func setCache(cache: Dictionary<String, NSObject>) {
        for (key, value) in cache {
            self.cache.setObject(value, forKey: key)
        }
    }
    
}