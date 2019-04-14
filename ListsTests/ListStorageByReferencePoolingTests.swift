//
//  ListStorageByReferencePoolingTests.swift
//  LinkedListExamples
//
//  Created on 2019/4/14.
//

import XCTest

@testable
import ListByReferencePooling

class ListStorageByReferencePoolingTests: XCTestCase {
    var storage: _ListStorage<Int>!
    
    override func setUp() {
        storage = .init()
    }
    
    override func tearDown() {
        storage = nil
    }
    
    // MARK: Init
    func testInit_setupsStorage() {
        XCTAssertEqual(storage._headNodeIndex, -1)
        XCTAssertTrue(storage._nodes.isEmpty)
        XCTAssertTrue(storage._reusableIndices.isEmpty)
        XCTAssertEqual(storage._count,0)
    }
    
    // MARK: Init with Storage
    func testInitWithStorage_copiesStorage() {
        storage.push(0)
        storage.push(1)
        _ = storage.pop()
        
        let copiedStorage = _ListStorage(storage)
        
        XCTAssertEqual(storage._headNodeIndex, copiedStorage._headNodeIndex)
        XCTAssertTrue(storage._nodes.elementsEqual(copiedStorage._nodes, by: {$0.element == $1.element && $0.next == $1.next}))
        XCTAssertEqual(storage._reusableIndices, copiedStorage._reusableIndices)
        XCTAssertEqual(storage._count, copiedStorage._count)
    }
    
    // MARK: Dequeue Reusable Node Index
    func test_dequeueReusableNodeIndex_dequeuesResuableNodeIndex_ifAnyReusableIndicesAreAvaialble() {
        var index = storage._dequeueReusableNodeIndex()
        storage._enqueueUnusedNode(at: index)
        index = storage._dequeueReusableNodeIndex()
        
        XCTAssertEqual(index, 0)
    }
    
    func test_dequeueReusableNodeIndex_dequeuesResuableNodeIndex_ifNoReusableIndicesAreAvaialble() {
        let index = storage._dequeueReusableNodeIndex()
        
        XCTAssertEqual(index, 0)
    }
    
    // MARK: Enqueue Unused Node at Index
    func test_enqueueUnusedNodeAtIndex_enqueuesUnusedNodeAtIndex() {
        let index = storage._dequeueReusableNodeIndex()
        storage._enqueueUnusedNode(at: index)
        XCTAssertTrue(storage._reusableIndices.contains(index))
    }
    
    func test_enqueueUnusedNodeAtIndex_cleansElement() {
        let index = storage._dequeueReusableNodeIndex()
        
        storage._nodes[index].element = 1
        
        storage._enqueueUnusedNode(at: index)
        
        XCTAssertEqual(storage._nodes[index].element, nil)
    }
    
    func test_enqueueUnusedNodeAtIndex_cleansNext() {
        let index = storage._dequeueReusableNodeIndex()
        
        storage._nodes[index].next = 1
        
        storage._enqueueUnusedNode(at: index)
        
        XCTAssertEqual(storage._nodes[index].next, -1)
    }
    
    // MARK: Push
    func testPush_pushesElement() {
        XCTAssertEqual(storage.count, 0)
        
        storage.push(1)
        
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.peek(), 1)
    }
    
    func testPush_pushesElements() {
        XCTAssertEqual(storage.count, 0)
        
        storage.push(1)
        
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.peek(), 1)
        
        storage.push(2)
        
        XCTAssertEqual(storage.count, 2)
        XCTAssertEqual(storage.peek(), 2)
    }
    
    // MARK: Pop
    func testPop_popsElement() {
        XCTAssertEqual(storage.count, 0)
        
        storage.push(1)
        
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.peek(), 1)
        
        let popped = storage.pop()
        
        XCTAssertEqual(popped, 1)
        XCTAssertEqual(storage.count, 0)
    }
    
    func testPop_popsElements() {
        XCTAssertEqual(storage.count, 0)
        
        storage.push(1)
        
        XCTAssertEqual(storage.count, 1)
        XCTAssertEqual(storage.peek(), 1)
        
        storage.push(2)
        
        XCTAssertEqual(storage.count, 2)
        XCTAssertEqual(storage.peek(), 2)
        
        var popped = storage.pop()
        
        XCTAssertEqual(popped, 2)
        XCTAssertEqual(storage.count, 1)
        
        popped = storage.pop()
        
        XCTAssertEqual(popped, 1)
        XCTAssertEqual(storage.count, 0)
    }
    
    // MARK: Peek
    func testPeek_peeksTopElement() {
        XCTAssertEqual(storage.count, 0)
        
        storage.push(1)
        
        let peeked = storage.peek()
        
        XCTAssertEqual(peeked, 1)
    }
}
