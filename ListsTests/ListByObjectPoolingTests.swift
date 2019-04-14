//
//  ListByObjectPoolingTests.swift
//  ListsTests
//
//  Created by Yu-Long Li on 2019/4/14.
//

import XCTest

@testable
import ListByObjectPooling

class ListByObjectPoolingTests: XCTestCase {
    var list: List<Int>!
    
    override func setUp() {
        list = .init()
    }
    
    override func tearDown() {
        list = nil
    }
    
    // MARK: Init
    func testInit_doesNotThrow() {
        XCTAssertNoThrow(List<Int>())
    }
    
    func testInit_createsDedicatedStorage() {
        var list = List<Int>()
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list._storage))
    }
    
    // MARK: Copy Assignment
    func testCopyAssignment_retainsStorage() {
        var list1 = List<Int>()
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list1._storage))
        
        var list2 = list1
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list1._storage))
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list2._storage))
        
        XCTAssertTrue(list1._storage === list2._storage)
    }
    
    // MARK: with Dedicated Storage
    func test_withDedicatedStorage_copiesStorage() {
        var list1 = List<Int>()
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list1._storage))
        
        var list2 = list1
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list1._storage))
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list2._storage))
        
        XCTAssertTrue(list1._storage === list2._storage)
        
        list2._withDedicatedStorage({ _ in })
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list1._storage))
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list2._storage))
        
        XCTAssertFalse(list1._storage === list2._storage)
    }
    
    // MARK: Push
    func testPush_pushesElement() {
        XCTAssertEqual(list.count, 0)
        
        list.push(1)
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.peek(), 1)
    }
    
    func testPush_pushesElements() {
        XCTAssertEqual(list.count, 0)
        
        list.push(1)
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.peek(), 1)
        
        list.push(2)
        
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.peek(), 2)
    }
    
    // MARK: Pop
    func testPop_popsElement() {
        XCTAssertEqual(list.count, 0)
        
        list.push(1)
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.peek(), 1)
        
        let popped = list.pop()
        
        XCTAssertEqual(popped, 1)
        XCTAssertEqual(list.count, 0)
    }
    
    func testPop_popsElements() {
        XCTAssertEqual(list.count, 0)
        
        list.push(1)
        
        XCTAssertEqual(list.count, 1)
        XCTAssertEqual(list.peek(), 1)
        
        list.push(2)
        
        XCTAssertEqual(list.count, 2)
        XCTAssertEqual(list.peek(), 2)
        
        var popped = list.pop()
        
        XCTAssertEqual(popped, 2)
        XCTAssertEqual(list.count, 1)
        
        popped = list.pop()
        
        XCTAssertEqual(popped, 1)
        XCTAssertEqual(list.count, 0)
    }
    
    // MARK: Peek
    func testPeek_peeksTopElement() {
        XCTAssertEqual(list.count, 0)
        
        list.push(1)
        
        let peeked = list.peek()
        
        XCTAssertEqual(peeked, 1)
    }
}

