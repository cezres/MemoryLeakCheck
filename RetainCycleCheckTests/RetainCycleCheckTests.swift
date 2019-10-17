//
//  RetainCycleCheckTests.swift
//  RetainCycleCheckTests
//
//  Created by 翟泉 on 2019/10/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import XCTest
@testable import RetainCycleCheck

class RetainCycleCheckTests: XCTestCase {

    func testRetainedObjects() {
        let obj1 = OCClass()
        let obj2 = OCClass()
        obj1.strongValue1 = obj2

        XCTAssert(obj1.retainedObjects().contains(obj2))
    }

    func testRetainCyclesCase1() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let obj1 = OCClass()
        let obj2 = OCClass()
        let obj3 = OCClass()

        obj1.strongValue1 = obj2
        obj2.strongValue1 = obj3
        obj3.strongValue1 = obj1

        var retainCycles = obj1.retainCycles()
        print(retainCycles)
        XCTAssertEqual(retainCycles.count, 1)   // obj1 在一个引用循环中，引用顺序是 [[1, 2, 3]]

        retainCycles = obj3.retainCycles()
        print(retainCycles)
        XCTAssertEqual(retainCycles.count, 1)   // obj3 在一个引用循环中，引用顺序是 [[3, 2, 1]]
    }

    func testRetainCyclesCase2() {
        let obj1 = OCClass()
        let obj2 = OCClass()
        let obj3 = OCClass()

        obj1.strongValue1 = obj2
        obj2.strongValue1 = obj3
        obj3.weakValue1 = obj1

        var retainCycles = obj1.retainCycles()
        XCTAssertEqual(retainCycles.count, 0)

        retainCycles = obj2.retainCycles()
        XCTAssertEqual(retainCycles.count, 0)
    }

    func testRetainCyclesCase3() {
        let obj1 = OCClass()
        let obj2 = OCClass()
        let obj3 = OCClass()
        let obj4 = OCClass()
        let obj5 = OCClass()

        obj1.strongValue1 = obj2
        obj1.strongValue2 = obj3
        obj1.strongValue3 = obj4

        obj2.strongValue1 = obj1
        obj2.strongValue2 = obj5
        obj2.weakValue1 = obj3

        obj3.strongValue1 = obj2
        obj3.strongValue2 = obj4
        obj3.strongValue3 = obj3

        var retainCycles = obj1.retainCycles()
        print(retainCycles)
        XCTAssertEqual(retainCycles.count, 2)   // obj1 在两个引用循环中，引用顺序是 [[1, 2], [1, 3, 2]]

        retainCycles = obj2.retainCycles()  // obj2 在两个引用循环中，引用顺序是 [[2, 1], [2, 1, 3]]
        print(retainCycles)
        XCTAssertEqual(retainCycles.count, 2)

        retainCycles = obj3.retainCycles()  // obj3 在两个引用循环中，引用顺序是 [[3, 2, 1], [3]]
        print(retainCycles)
        XCTAssertEqual(retainCycles.count, 2)
    }

}
