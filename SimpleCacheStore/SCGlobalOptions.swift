//
//  SCGlobalOptions.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation

class SCGlobalOptions {
    
    struct Options {
        static var cacheLimit: Int = 0
        static var cacheMode: SCManager.CacheMode = SCManager.CacheMode.Rebuild
    }
}