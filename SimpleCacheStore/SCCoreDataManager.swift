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
    
    fileprivate var persistentContainer: NSPersistentContainer?
    
    init() {
        let coreDataHandler = CoreDataHandler(container: "SimpleCache")
        self.persistentContainer = coreDataHandler.getPersistentContainer()
        
    }
    
    private func getPrivateManagedContext() -> NSManagedObjectContext? {
        return self.persistentContainer?.newBackgroundContext()
    }
    
    func saveObject(forKey: String, object:NSObject, label: String) {
        guard let container = self.persistentContainer else {
            return
        }
        container.performBackgroundTask {
            (context) in
            // Iterates the array
            let storedObject = StoredObject(context: context)
            storedObject.identifier = forKey
            storedObject.object = NSKeyedArchiver.archivedData(withRootObject: object)
            storedObject.created = Date()
            storedObject.label = label
            storedObject.lastUpdate = Date()
            storedObject.requested = 0
            
            do {
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }

    func getObject(forKey: String, answer: @escaping (Bool, NSObject?) -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredObject")
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
        
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { asynchronousFetchResult in
            guard let result = asynchronousFetchResult.finalResult as? [StoredObject] else {
                answer(false, nil)
                return
            }
            
            if !result.isEmpty {
                if let object = result[0].object {
                    if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: object) as? NSObject {
                        //self.updateRequestRefCounter(forKey: result[0].identifier!)
                        answer(true, retrievedObject)
                    } else {
                        answer(false, nil)
                    }
                } else {
                    answer(false, nil)
                }
            }
        }
        
        guard let pmc = self.getPrivateManagedContext() else {
            answer(false, nil)
            return
        }
        
        do {
            try pmc.execute(asynchronousFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest error: \(error)")
        }
    }
    
    func getObjects(byLabel: String, answer: @escaping (Bool, [NSObject]?) ->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "StoredObject")
        fetchRequest.predicate = NSPredicate(format: "label == %@", byLabel)
        
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            asynchronousFetchResult in
            
            var answerObjects = [NSObject]()
            
            guard let result = asynchronousFetchResult.finalResult as? [StoredObject] else {
                answer(false, nil)
                return
            }
            
            if !result.isEmpty {
                for storedObject in result {
                    if let object = result[0].object {
                        if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: object) as? NSObject {
                            //self.updateRequestRefCounter(forKey: result[0].identifier!)
                            answerObjects.append(retrievedObject)
                        }
                    }
                }
            }
            answer(true, answerObjects)
        }
        
        guard let pmc = self.getPrivateManagedContext() else {
            answer(false, nil)
            return
        }
        
        do {
            try pmc.execute(asynchronousFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest error: \(error)")
        }
    }
    
    func updateRequestRefCounter(forKey: String) {
        /*let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
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
                            SCLog.sharedInstance.write(function: "\(#function)", message: "Update ref counter in main context failed for object: " + forKey)
                        }
                    })
                } catch {
                    SCLog.sharedInstance.write(function: "\(#function)", message: "Update ref counter in private context failed for object: " + forKey)
                }
                
            } catch {
                SCLog.sharedInstance.write(function: "\(#function)", message: "Failed object update at fetching information for object: " + forKey)
            }
        })*/
    }
    
    func getAllObjects(answer: @escaping (Bool, [NSObject]?) -> ()) {
        /*let pMOC = self.initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var answerArr:[NSObject] = [NSObject]()
                for cacheObject in result {
                    if let coObject = cacheObject.object {
                        /*if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            answerArr.append(retrievedObject)
                        }*/
                    }
                }
                answer(true, answerArr)
            } catch {
                answer(false, nil)
                SCLog.sharedInstance.write(function: "\(#function)", message: "Error while reading data")
            }
        })*/
    }
    
    func getObjectDump(answer: @escaping (Dictionary<String, NSObject>?) -> ()) {
        /*let pMOC = initPrivateMOC()
        
        pMOC.perform({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            
            let entityDescription = NSEntityDescription.entity(forEntityName: "CacheObject", in: pMOC)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                var dict: Dictionary<String, NSObject> = [String: NSObject]()
                for cacheObject in result {
                    if let coObject = cacheObject.object, let id = cacheObject.identifier {
                        /*if let retrievedObject = NSKeyedUnarchiver.unarchiveObject(with: coObject) as? NSObject {
                            dict[id] = retrievedObject
                        }*/
                    }
                }
                answer(dict)
            } catch {
                answer(nil)
                SCLog.sharedInstance.write(function: "\(#function)", message: "Error while reading data")
            }
        })*/
    }
    
    func delete(forKey: String, answer: @escaping (Bool) -> ()) {
        guard let container = self.persistentContainer else {
            answer(false)
            return
        }
        
        container.performBackgroundTask {
            context in
            
            let storedObject: StoredObject = StoredObject(context: context)
            storedObject.identifier = forKey
            
            do {
                context.delete(storedObject)
                
                // Saves in private context
                try context.save()
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
        /*let pMOC = initPrivateMOC()
    
        pMOC.performAndWait({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
            fetchRequest.predicate = NSPredicate(format: "identifier == %@", forKey)
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                
                for cacheObject in result {
                    pMOC.delete(cacheObject)
                }
                
                do {
                    try pMOC.save()
                    self.managedObjectContext?.performAndWait({
                        do {
                            try self.managedObjectContext?.save()
                            answer(true)
                        } catch {
                            SCLog.sharedInstance.write(function: "\(#function)", message: "Failed to delete data in main contexFait for object: " + forKey)
                            answer(false)
                        }
                    })
                } catch {
                    SCLog.sharedInstance.write(function: "\(#function)", message: "Failed to delete data in private context for object: " + forKey)
                    answer(false)
                }
            } catch {
                SCLog.sharedInstance.write(function: "\(#function)", message: "Failed to delete data for object: " + forKey)
                answer(false)
            }
        })*/
    
    }
    
    func clearCoreData(cleared: @escaping (Bool) -> ()) {
        
        /*self.managedObjectContext?.performAndWait({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
            let request = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.managedObjectContext?.execute(request)
                try self.managedObjectContext?.save()
                cleared(true)
            } catch {
                SCLog.sharedInstance.write(function: "\(#function)", message: "Failed to clear CoreData")
                cleared(false)
            }
        })*/
        /*
        let pMOC = self.initPrivateMOC()
        
        pMOC.performAndWait({
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CacheObject")
            
            do {
                let result = try pMOC.fetch(fetchRequest) as! [CacheObject]
                
                for cacheObject in result {
                    pMOC.delete(cacheObject)
                }
            } catch {
                SCLog.sharedInstance.write(function: "\(#function)", message: "Failed to fetch Objects for clearing storage")
            }
            
            do {
                try pMOC.save()
                self.managedObjectContext?.performAndWait({
                    do {
                        try self.managedObjectContext?.save()
                        cleared(true)
                    } catch {
                        SCLog.sharedInstance.write(function: "\(#function)", message: "Saving object in main context failed")
                    }
                })
            } catch {
                SCLog.sharedInstance.write(function: "\(#function)", message: "Saving object in private context failed")
            }
        })*/
        
    }
}
