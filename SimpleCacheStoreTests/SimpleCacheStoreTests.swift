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
    var obj1: TestObject!
    var obj2: TestObject!
    var obj3: TestObject!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        obj1 = TestObject(name: "Objekt 1", status: "Ich habe den ersten Status")
        obj2 = TestObject(name: "Objekt 2", status: "Ich habe den zweiten Status")
        obj3 = TestObject(name: "Other Object 3", status: "Nicht was du suchst")
        
        scm.save(forKey: "testobj1", object: obj1, label: "testobj")
        scm.save(forKey: "testobj2", object: obj2, label: "testobj")
        scm.save(forKey: "otherobj2", object: obj3, label: "otherobj")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        scm.clear()
    }
    
    func testSyncGet() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let swapObj1 = scm.get(forKey: "testobj1") as! TestObject
        let swapObj2 = scm.get(forKey: "testobj2") as! TestObject
        
        XCTAssertTrue(swapObj1.name == obj1.name, "No match")
        XCTAssertTrue(swapObj2.name == obj2.name, "No Match")
        
    }
    
    func testAsyncGet() {
        
        let expec1 = expectation(description: "Object 1 async")
        let expec2 = expectation(description: "Object 2 async")
        
        scm.get(forKey: "testobj1", answer: {
            success, obj in
            let swapObj1 = obj as! TestObject
            XCTAssertTrue(swapObj1.name == self.obj1.name, "No match")
            expec1.fulfill()
        })
        scm.get(forKey: "testobj2", answer: {
            success, obj in
            let swapObj2 = obj as! TestObject
            XCTAssertTrue(swapObj2.name == self.obj2.name, "No match")
            expec2.fulfill()
        })
        
        self.waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Failure in async single get")
        })
    }
    
    func testSyncGetLabel() {
        let swapObjArr = scm.get(byLabel: "testobj") as! [TestObject]
        for swapObj in swapObjArr {
            XCTAssertTrue(swapObj.name == obj1.name || swapObj.name == obj2.name, "No match")
        }
    }
    
    func testAsyncGetLabel() {
        
        let expec = expectation(description: "Get All Objects for label")
        
        scm.get(byLabel: "testobj", answer: {
            success, objects in
            let swapObjArr = objects as! [TestObject]
            for swapObj in swapObjArr {
                XCTAssertTrue(swapObj.name == self.obj1.name || swapObj.name == self.obj2.name, "No match")
            }
            XCTAssertEqual(swapObjArr.count, 2)
            expec.fulfill()
        })
        
        self.waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        let objMeasure = TestObject(name: "Other Object Measure", status: "Nicht was du suchst")

        self.measure {
            // Put the code you want to measure the time of here.
            _ = self.scm.get(byLabel: "testobj")
        }
    }
    
    func testPerformanceExample2() {
        // This is an example of a performance test case.
        let objMeasure = TestObject(name: "Other Object Measure", status: "Nicht was du suchst")
        
        self.measure {
            // Put the code you want to measure the time of here.
            _ = self.scm.get(byLabel: "testobj")
        }
    }
    
}
