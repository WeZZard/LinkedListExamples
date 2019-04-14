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
    
    // MARK: Ensure Dedicated Storage
    func test_ensureDedicatedStorage_copiesStorage() {
        var list1 = List<Int>()
        
        XCTAssertTrue(isKnownUniquelyReferenced(&list1._storage))
        
        var list2 = list1
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list1._storage))
        
        XCTAssertFalse(isKnownUniquelyReferenced(&list2._storage))
        
        XCTAssertTrue(list1._storage === list2._storage)
        
        list2._ensureDedicatedStorage()
        
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
    
    // MARK: Collection
    func testSubscript_returnsElementAtIndex() {
        list.push(0)
        list.push(1)
        list.push(2)
        
        let i1 = list.startIndex
        let i2 = list.index(after: i1)
        let i3 = list.index(after: i2)
        
        XCTAssertEqual(list[i1], 2)
        XCTAssertEqual(list[i2], 1)
        XCTAssertEqual(list[i3], 0)
    }
    
    func testIndexAfter_increasesOffset() {
        let i1 = list.startIndex
        let i2 = list.index(after: i1)
        
        XCTAssertTrue(i2._offset - 1 == i1._offset)
    }
    
    func testStartIndex_returnsIndexOfOffsetAtZero() {
        let i = list.startIndex
        
        XCTAssertEqual(i._offset, 0)
    }
    
    func testEndIndex_returnsIndexOfOffsetAtZero_withNoContent() {
        let i = list.endIndex
        
        XCTAssertEqual(i._offset, 0)
    }
    
    func testEndIndex_returnsIndexOfOffsetAtPastTheEnd_withContents() {
        list.push(0)
        
        let i = list.endIndex
        
        XCTAssertEqual(i._offset, 1)
    }
    
    // MARK: Sequence
    func testSequence() {
        list.push(0)
        list.push(1)
        list.push(2)
        
        let array = Array(list)
        
        XCTAssertEqual(array, [2, 1, 0])
    }
}

