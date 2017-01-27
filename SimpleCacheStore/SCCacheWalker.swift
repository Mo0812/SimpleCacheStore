//
//  SCCacheWalker.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 23.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class SCCacheWalker {
    
    let cm: SCCacheManager
    let  moc: NSManagedObjectContext?
    
    init() {
        cm = SCCacheManager.sharedInstance
        let cdh = CoreDataHandler(identifier: "MK.SimpleCacheStore", ressource: "SCSnapshot")
        moc = cdh.getMOC()
    }
    
    func saveSnapshot() {
        
        let cacheDictionary = cm.getCacheDictionary()
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Snapshot", into: self.moc!) as! Snapshot
        entity.setValue(Date(), forKey: "created")
        
        let cacheData =  NSKeyedArchiver.archivedData(withRootObject: cacheDictionary)
        entity.setValue(cacheData, forKey: "data")
        
        
        do {
            try self.moc?.save()
        } catch {
            
        }
        
        print("SNAPSHOT ERSTELLT")
        
    }
    
    func restoreSnapshot() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Snapshot", in: self.moc!)
        
        fetchRequest.entity = entityDescription
        //fetchRequest.predicate = NSPredicate(format: "created <= %@", NSDate())
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        
        do {
            let result = try self.moc?.fetch(fetchRequest) as! [Snapshot]
            if !result.isEmpty {
                
                if let latestSnapShot = result[0].data {
                    if let snapshot = NSKeyedUnarchiver.unarchiveObject(with: latestSnapShot) as? Dictionary<String, NSObject> {
                        cm.setCache(snapshot)
                    }
                }
            }
        } catch {
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
        
        print("SNAPSHOT RESTORED")
    }
    
    func establishCacheFromPersistentObjects(_ answer: @escaping (Bool) -> ()) {
        let cdm = SCCoreDataManager()
        /*let operationQueue = NSOperationQueue()
        operationQueue.addOperationWithBlock({
            cdm.getObjectDump({
                objectDict in
                if let persistentObjects = objectDict {
                    self.cm.setCache(persistentObjects)
                    answer(true)
                }
            })
        })*/
        SCGlobalOptions.Options.concurrentSCSQueue.async(execute: {
            cdm.getObjectDump({
                objectDict in
                if let persistentObjects = objectDict {
                    self.cm.setCache(persistentObjects)
                    answer(true)
                }
            })
        })
    }
    
}
