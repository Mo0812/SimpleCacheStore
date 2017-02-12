//
//  SimpleCacheStoreTests.swift
//  SimpleCacheStoreTests
//
//  Created by Moritz Kanzler on 31.01.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import XCTest
@testable import SimpleCacheStore

class SimpleCacheStoreTests: XCTestCase {
    
    let scm = SCManager(cacheMode: .rebuild, cacheLimit: 100)
    var objContainer: [TestObject]!
    var otherContainer: [TestObject]!
    var objCounter = 1000
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        objContainer = [TestObject]()
        otherContainer = [TestObject]()
        
        for i in 0..<objCounter {
            let objKey = "testobj" + String(i)
            let objName = "Object " + String(i)
            let objStatus = "Status " + String(i)
            let obj = TestObject(name: objName, status: objStatus)
            var label = "other"
            
            if i < objCounter/2 {
                label = "testobj"
                objContainer.append(obj)
                
            } else {
                otherContainer.append(obj)
            }
            scm.save(forKey: objKey, object: obj, label: label)

        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        scm.clear()
        objContainer.removeAll()
        otherContainer.removeAll()
    }
    
    func testAsyncGet() {
        
        let expec1 = expectation(description: "Object Random 1 async")
        let expec2 = expectation(description: "Object Random 2 async")
        
        let objIndex1 = Int(arc4random_uniform(UInt32(objContainer.count)))
        let objIndex2 = Int(arc4random_uniform(UInt32(otherContainer.count)))
        
        let key1 = "testobj" + String(objIndex1)
        let key2 = "testobj" + String(objIndex2)
        
        scm.get(forKey: key1, answer: {
            success, obj in
            let swapObj = obj as! TestObject
            XCTAssertTrue(swapObj.name == self.objContainer[objIndex1].name, "No match")
            expec1.fulfill()
        })
        scm.get(forKey: key2, answer: {
            success, obj in
            let swapObj = obj as! TestObject
            XCTAssertTrue(swapObj.name == self.objContainer[objIndex2].name, "No match")
            expec2.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Failure in async single get")
        })
    }
    
    func testAsyncGetLabel() {
        
        let expec = expectation(description: "Get All Objects for label")
        
        scm.get(byLabel: "testobj", answer: {
            success, objects in
            let swapObjArr = objects as! [TestObject]
            XCTAssertTrue(swapObjArr.count == self.objContainer.count, "No match")
            var i = 0
            for swapObj in swapObjArr {
                XCTAssertTrue(swapObj.name == self.objContainer[i].name, "No match")
                i+=1
            }
            XCTAssertEqual(swapObjArr.count, self.objCounter / 2)
            expec.fulfill()
        })
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            
        }
    }
    
//    func testOverwrite() {
//        
//        let objPure = TestObject(name: "overwriteObj", status: "Before overwriting")
//        scm.save(forKey: "overwriteObj", object: objPure, label: "overwrite")
//        let obj = scm.get(forKey: "overwriteObj") as! TestObject
//        XCTAssertTrue(obj.status == objPure.status , "No match")
//        
//        let objEdit = TestObject(name: "overwriteObj", status: "After overwriting")
//        scm.save(forKey: "overwriteObj", object: objEdit, label: "overwrite")
//        let objEdited = scm.get(forKey: "overwriteObj") as! TestObject
//        XCTAssertTrue(objEdited.status == objEdit.status , "No match")
//                
//    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        let objMeasure = TestObject(name: "Other Object Measure", status: "Nicht was du suchst")

        self.measure {
            // Put the code you want to measure the time of here.
            _ = self.scm.get(byLabel: "testobj")
        }
    }*/
    
}
