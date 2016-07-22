//
//  CacheManager.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 15.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class SCCoreDataManager {
    
    enum SCCDataManagerErrorType {
        case None
        case Duplicate
        case CoreDataAccessError
        case GenericError
    }
    
    private var managedObjectContext: NSManagedObjectContext?
    private var lockTable: [String: Bool]?
    
    init() {
        let coreDataHandler = CoreDataHandler()
        self.managedObjectContext = coreDataHandler.getMOC()
        
        /****
         * Lock Mode Table
        ****/
        self.lockTable = [String: Bool]()
        
    }
    
    func saveObject(forKey: String, object:NSObject) -> Bool {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            if result.count > 0 {
                self.managedObjectContext?.deleteObject(result[0])
            }
            let entity = NSEntityDescription.insertNewObjectForEntityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!) as! CacheObject
            entity.setValue(forKey, forKey: "identifier")
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            entity.setValue(data, forKey: "object")
            
            entity.setValue(NSDate(), forKey: "created")
            
            do {
                try self.managedObjectContext?.save()
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }
    
    func saveObject(forKey: String, object: NSObject, answer: (Bool, String) -> ()) {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            if result.count > 0 {
                self.managedObjectContext?.deleteObject(result[0])
            }
            let entity = NSEntityDescription.insertNewObjectForEntityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!) as! CacheObject
            entity.setValue(forKey, forKey: "identifier")
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            entity.setValue(data, forKey: "object")
            
            entity.setValue(NSDate(), forKey: "created")
            
            do {
                try self.managedObjectContext?.save()
                answer(true, "")
            } catch {
                answer(false, "[CacheManager:save] -> Fehler beim Speichern")
            }
        } catch {
            answer(false, "")
        }
        
    }
    
    func getObject(forKey: String, answer: (Bool, NSObject?) -> ()) {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            var answerObject:NSObject?
            if !result.isEmpty {
                if let coObject = result[0].object {
                    if let retrievedObject = NSKeyedUnarchiver.unarchiveObjectWithData(coObject) as? NSObject {
                        answerObject = retrievedObject
                    }
                }
            }
            answer(true, answerObject)
        } catch {
            answer(false, nil)
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
    }
    
    func getObject(forKey: String) -> NSObject? {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            var answerObject:NSObject?
            if !result.isEmpty {
                if let coObject = result[0].object {
                    if let retrievedObject = NSKeyedUnarchiver.unarchiveObjectWithData(coObject) as? NSObject {
                        answerObject = retrievedObject
                    }
                }
            }
            return answerObject
        } catch {
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
        return nil
    }
    
    func getAllObjects(answer: (Bool, [NSObject]?) -> ()) {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            var answerArr:[NSObject] = [NSObject]()
            for cacheObject in result {
                if let coObject = cacheObject.object {
                    if let retrievedObject = NSKeyedUnarchiver.unarchiveObjectWithData(coObject) as? NSObject {
                        answerArr.append(retrievedObject)
                    }
                }
            }
            answer(true, answerArr)
        } catch {
            answer(false, nil)
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
    }
    
   func deleteObject(forKey: String) {
        let fetchRequest = NSFetchRequest(entityName: "CacheObject")
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            
            for cacheObject in result {
                self.managedObjectContext?.deleteObject(cacheObject)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            // Do something in response to error condition
        }
    }
    
  func clearCache() {
        let fetchRequest = NSFetchRequest(entityName: "CacheObject")
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            
            for cacheObject in result {
                self.managedObjectContext?.deleteObject(cacheObject)
            }
        } catch {
            // Do something in response to error condition
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            // Do something in response to error condition
        }
    }
}