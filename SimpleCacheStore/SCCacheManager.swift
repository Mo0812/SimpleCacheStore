//
//  SCCacheManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

class SCCacheManager {
    
    private var cache: NSCache?
    
    init() {
        cache = NSCache()
    }
    
    func saveObjectToCache(forKey: String, object: NSObject) {
        if let cache = cache {
            if let cachedVersion = cache.objectForKey(forKey) {
                cache.removeObjectForKey(forKey)
            }
            cache.setObject(object, forKey: forKey)
        }
    }
    
    func getObjectFromCache(forKey: String) -> NSObject? {
        if let cache = cache {
            if let cachedVersion = cache.objectForKey(forKey) as? NSObject {
                return cachedVersion
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}