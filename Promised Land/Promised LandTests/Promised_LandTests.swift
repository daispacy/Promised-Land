//
//  Promised_LandTests.swift
//  Promised LandTests
//
//  Created by Dai Pham on 3/20/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import XCTest
@testable import Promised_Land

class Promised_LandTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let promise = expectation(description: "test")
        Server.getListTeams { (list) in
            if let list = list  {
                print(list)
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 60, handler: nil)
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
