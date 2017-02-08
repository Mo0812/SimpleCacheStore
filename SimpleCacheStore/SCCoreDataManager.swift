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
        case none
        case duplicate
        case coreDataAccessError
        case genericError
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext?
    
    init() {
        let coreDataHandler = CoreDataHandler(identifier: "MK.SimpleCacheStore", ressource: "SimpleCache")
        self.managedObjectContext = coreDataHandler.getMOC()
        
    }
    
    func initPrivateMOC() -> NSManagedObjectContext {
        let pMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        pMOC.parent = self.managedObjectContext
        
        return pMOC
    }
    
    func saveObject(forKey: String, object:NSObject, label: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)      
        
        do {
            
            var created = Date()
            var lastUpdate = Date()
            var requested: UInt64 = 0
            
            let result = try self.managedObjectContext?.fetch(fetchRequest) as! [CacheObject]
            if result.count > 0 {
                created = result[0].created!
                lastUpdate = Date()
                requested = UInt64(result[0].requested)
                
                self.managedObjectContext?.delete(result[0])
                
            }
            
            let entity = NSEntityDescription.insertNewObject(forEntityName: "CacheObject", into: self.managedObjectContext!) as! CacheObject
            
            entity.setValue(forKey, forKey: "identifier")
            
            let data = NSKeyedArchiver.archivedData(withRootObject: object)
            entity.setValue(data, forKey: "object")
            
            entity.setValue(created, forKey: "created")
            
            entity.setValue(label, forKey: "label")
            
            entity.setValue(lastUpdate, forKey: "lastUpdate")
            
            entity.setValue(requested, forKey: "requested")
            
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
    
    func saveObject(forKey: String, object: NSObject) -> Bool {
        return self.saveObject(forKey: forKey, object: object, label: SCGlobalOptions.Options.defaultLabel)
    }
    
    /*func saveObject(_ forKey: String, object: NSObject, answer: @escaping (Bool, String) -> ()) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
            
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                if result.count > 0 {
                    pMOC.delete(result[0])
                }
                let entity = NSEntityDescription.insertNewObject(forEntityName: "CacheObject", into: pMOC) as! CacheObject
                entity.setValue(forKey, forKey: "identifier")
                
                let data = NSKeyedArchiver.archivedData(withRootObject: object)
                entity.setValue(data, forKey: "object")
                
                entity.setValue(Date(), forKey: "created")
                
                do {
                    try pMOC.save()
                    answer(true, "")
                } catch {
                    answer(false, "[CacheManager:save] -> Fehler beim Speichern")
                }
            } catch {
                answer(false, "")
            }
        })
        
    }*/
    
    func getObject(forKey: String, answer: @escaping (Bool, NSObject?) -> ()) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
            
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var answerObject:NSObject?
                if !result.isEmpty {
                    if let coObject = result[0].object {
                        if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            answerObject = retrievedObject
                        }
                    }
                }
                answer(true, answerObject)
            } catch {
                answer(false, nil)
                fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
            }
        })
    }
    
    func getObject(forKey: String) -> NSObject? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        
        do {
            let result = try self.managedObjectContext?.fetch(fetchRequest) as! [CacheObject]
            var answerObject:NSObject?
            if !result.isEmpty {
                if let coObject = result[0].object {
                    if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
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
    
    func getObjects(byLabel: String, answer: @escaping (Bool, [NSObject]?) ->()) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate(format: "label == %@", byLabel)
            
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var answerObjects = [NSObject]()

                if !result.isEmpty {
                    for rawObj in result {
                        if let coObject = rawObj.object {
                            if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                                answerObjects.append(retrievedObject)
                            }
                        }
                    }
                }
                answer(true, answerObjects)
            } catch {
                answer(false, nil)
                fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
            }
        })
    }
    
    func getObjects(byLabel: String) -> [NSObject]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "label == %@", byLabel)
        
        
        do {
            let result = try self.managedObjectContext?.fetch(fetchRequest) as! [CacheObject]
            var answerObjects = [NSObject]()
            
            if !result.isEmpty {
                print(result)
                for rawObj in result {
                    if let coObject = rawObj.object {
                        if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            answerObjects.append(retrievedObject)
                        }
                    }
                }
            } else {
                
            }
            return answerObjects
        } catch {
            fatalError("[CacheManager:getObjects] -> Fehler beim Lesen von Daten")
        }
        return nil
    }
    
    func getAllObjects(answer: @escaping (Bool, [NSObject]?) -> ()) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var answerArr:[NSObject] = [NSObject]()
                for cacheObject in result {
                    if let coObject = cacheObject.object {
                        if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            answerArr.append(retrievedObject)
                        }
                    }
                }
                answer(true, answerArr)
            } catch {
                answer(false, nil)
                fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
            }
        })
    }
    
    func getObjectDump(answer: @escaping (Dictionary<String, NSObject>?) -> ()) {
        let pMOC = initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var dict: Dictionary<String, NSObject> = [String: NSObject]()
                for cacheObject in result {
                    if let coObject = cacheObject.object, let id = cacheObject.identifier {
                        if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            dict[id] = retrievedObject
                        }
                    }
                }
                answer(dict)
            } catch {
                answer(nil)
                fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
            }
        })
    }
    
   func deleteObject(forKey: String) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        do {
            let result = try self.managedObjectContext?.fetch(fetchRequest) as! [CacheObject]
            
            for cacheObject in result {
                self.managedObjectContext?.delete(cacheObject)
            }
        } catch {
            return false
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            return false
        }
        return true
    }
    
  func clearCache() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
        
        do {
            let result = try self.managedObjectContext?.fetch(fetchRequest) as! [CacheObject]
            
            for cacheObject in result {
                self.managedObjectContext?.delete(cacheObject)
            }
        } catch {
            return false
        }
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            return false
        }
        return true
    }
}
