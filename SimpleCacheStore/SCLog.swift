//
//  SCLog.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 16.02.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import Foundation

class SCLog {
    
    static let sharedInstance = SCLog(debug: SCGlobalOptions.Options.debugMode)
    let logFile: String
    let debugMode: Bool
    
    init(debug: Bool) {
        self.logFile = "scserror.log"
        self.debugMode = debug
        
    }
    
    func write(function: String, message: String) {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(self.logFile)
            let outputPattern = "[\(Date())]" + SCGlobalOptions.Options.scsDebugIdentifier + "[\(function)]" + " -> \(message)"
            
            //writing
            do {
                try outputPattern.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                if(self.debugMode) {
                    print(outputPattern)
                }
                
            }
            catch {
                print(SCGlobalOptions.Options.scsDebugIdentifier + "[\(#function)]" + " -> Error writing file")
            }
            
            //reading
            /*do {
                let text2 = try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}*/
        }
    }
    
    func read() -> String? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(self.logFile)
            
            do {
                let log = try String(contentsOf: path, encoding: String.Encoding.utf8)
                return log
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
}
