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
    
    func saveObject(forKey: String, object:NSObject, label: String) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.performAndWait({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: self.managedObjectContext!)
            
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
            
            do {
                
                let data = NSKeyedArchiver.archivedData(withRootObject: object)
                
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                if result.count > 0 {
                    
                }/*
                
                    let created = result[0].created!
                    let requested = Int64(result[0].requested)
                    
                    result[0].object = data
                    result[0].created = created
                    result[0].label = label
                    result[0].lastUpdate = Date()
                    result[0].requested = requested
                    
                    //self.managedObjectContext?.delete(result[0])*/
                    
                else {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: "CacheObject", into: self.managedObjectContext!) as! CacheObject
                    
                    entity.setValue(forKey, forKey: "identifier")
                    
                    entity.setValue(data, forKey: "object")
                    
                    entity.setValue(Date(), forKey: "created")
                    
                    entity.setValue(label, forKey: "label")
                    
                    entity.setValue(Date(), forKey: "lastUpdate")
                    
                    entity.setValue(0, forKey: "requested")
                }
                
                do {
                    try pMOC.save()
                    self.managedObjectContext?.performAndWait({
                        do {
                            try self.managedObjectContext?.save()
                        } catch {
                            fatalError("MOC save failed")
                        }
                    })
                } catch {
                    fatalError("pMOC save failed")
                }
            } catch {
                fatalError("pMOC save failed")
            }
        })
        
    }
    
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
                        self.updateRequestRefCounter(forKey: forKey)
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
                            self.updateRequestRefCounter(forKey: rawObj.identifier!)
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
    
    func updateRequestRefCounter(forKey: String) {
        let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: self.managedObjectContext!)
            
            fetchRequest.entity = entityDescription
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
            
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                if !result.isEmpty {
                    result[0].requested += 1
                }
                
                do {
                    try pMOC.save()
                    self.managedObjectContext?.performAndWait({
                        do {
                            try self.managedObjectContext?.save()
                        } catch {
                            fatalError("MOC save failed")
                        }
                    })
                } catch {
                    fatalError("[CacheManager:updateRequestRefCounter] -> Fehler beim Aktualisieren des RefCounters")
                }
                
            } catch {
                fatalError("[CacheManager:updateRequestRefCounter] -> Fehler beim Aktualisieren des RefCounters")
            }
        })
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
