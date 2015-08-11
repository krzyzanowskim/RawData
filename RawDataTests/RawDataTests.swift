//
//  RawDataTests.swift
//  RawDataTests
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import XCTest
@testable import RawData

class RawDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInit() {
        let data = RawData(5)
        XCTAssert(data.count == 5, "Invalid count")
        XCTAssert(data[0] == 0, "Invalid first value")
        XCTAssert(data[4] == 0, "Invalid first value")
    }
    
    func testInitFromArray() {
        let arr:[UInt8] = [1,2,3,4,5,6]
        XCTAssertTrue(RawData(arr) == RawData([1,2,3,4,5,6]))
    }
    
    func testArrayLiteralConvertible() {
        let data:RawData = [1,2,3]
        XCTAssertTrue(data[0] == 1 && data[1] == 2 && data[2] == 3)
    }
    
    func testArray() {
        let data: RawData = [1,2,3]
        let arr = Array(data)
        XCTAssertTrue(arr[0] == 1 && arr[1] == 2 && arr[2] == 3)
    }
    
    func testIntegerLiteralConvertible() {
        let data:RawData = 5
        XCTAssertTrue(data[0] == 5)
    }
    
    func testCustomStringConvertible() {
        XCTAssertTrue(([1,2,3,4,5,6] as RawData).description == "<01020304 0506>")
        XCTAssertTrue(([1,2] as RawData).description == "<0102>")
        XCTAssertTrue(([] as RawData).description == "<>")
    }
    
    func testReplace() {
        let data:RawData = [1,2,3,4]
        data[0] = 9
        XCTAssertTrue(data[0] == 9)
    }
    
    func testRangeReplaceableCollectionType() {
        let data:RawData = [1,2,3,4,5,6,7,8,9,10]
        data.replaceRange(0...3, with: [10,9,8])
        XCTAssertTrue(data[0] == 10 && data[1] == 9 && data[2] == 8 && data[3] == 4)
    }
    
    func testCount() {
        let data:RawData = [1,2,3]
        XCTAssertTrue(data.count == 3)
        XCTAssertEqual(data.endIndex, 3)
        
        let dataEmpty:RawData = []
        XCTAssertEqual(dataEmpty.count, 0)
        XCTAssertEqual(dataEmpty.endIndex, 0)
    }
    
    func testCopy() {
        let data:RawData = [1,2,3]
        let copy = RawData(data)
        XCTAssertTrue(data == copy)
    }
    
    func testShiftLeft() {
        let data:RawData = [1,2,3,4,5,6,7,8]
        let shifted = data << 5
        XCTAssertTrue(shifted == RawData([6,7,8,0,0,0,0,0]))
        XCTAssertFalse(shifted == RawData([7,8,0,0,0,0,0,0]))
    }
    
    func testShiftRight() {
        let data:RawData = [1,2,3,4,5,6,7,8]
        let shifted = data >> 5
        XCTAssertTrue(shifted == RawData([0,0,0,0,0,1,2,3]))
        XCTAssertFalse(shifted == RawData([0,0,0,0,0,0,1,2]))
    }

    func testOr() {
        let data1:RawData = [0,0,0,0,5,6,7,8]
        let data2:RawData = [1,2,3,4,0,0,0,0]
        XCTAssertTrue(data1 | data2 == RawData([1,2,3,4,5,6,7,8]))
    }
}
