//
//  ListStorageByObjectPoolingTests.swift
//  LinkedListExamples
//
//  Created on 2019/4/14.
//

import XCTest

@testable
import ListByObjectPooling

class ListStorageByObjectPoolingTests: XCTestCase {
    var storage: _ListStorage<Int>!
    
    override func setUp() {
        storage = .init()
    }
    
    override func tearDown() {
        storage = nil
    }
    
    // MARK: Init
    func testInit_setupsStorage() {
        XCTAssertEqual(storage._buffer, nil)
        XCTAssertEqual(storage._count, 0)
        XCTAssertEqual(storage._capacity, 0)
        XCTAssertEqual(storage._headOffset, -1)
        XCTAssertEqual(storage._reuseHeadOffset, -1)
    }
    
    // MARK: Init with Storage
    func testInitWithStorage_copiesStorage() {
        let copiedStorage = _ListStorage(storage)
        
        XCTAssertEqual(storage._count, copiedStorage._count)
        XCTAssertEqual(storage._capacity, copiedStorage._capacity)
        XCTAssertEqual(storage._headOffset, copiedStorage._headOffset)
        XCTAssertEqual(storage._reuseHeadOffset, copiedStorage._reuseHeadOffset)
        
        XCTAssertEqual(copiedStorage._buffer, nil)
    }
    
    // MARK: Grow Buffer If Needed
    func test_growBufferIfNeeded_growsBufferWithAtLeastOneAndHalfTimesCapacity() {
        let capacity1 = storage._capacity
        
        storage._growBufferIfNeeded()
        
        let capacity2 = storage._capacity
        
        XCTAssertTrue(capacity2 >= (capacity1 + ((capacity1 + 1) >> 1)))
    }
    
    func test_growBufferIfNeeded_sets_reuseHeaderOffsetToTheCapacityOfTheOldBuffer() {
        let oldCapacity = storage._capacity
        
        storage._growBufferIfNeeded()
        
        XCTAssertEqual(storage._reuseHeadOffset, oldCapacity)
    }
    
    func test_growBufferIfNeeded_linksGrownBuckets() {
        let capacity1 = storage._capacity
        
        storage._growBufferIfNeeded()
        
        let capacity2 = storage._capacity
        
        for offset in capacity1..<max(0, capacity2 - 1) {
            let bucketPtr = storage._buffer.advanced(by: offset)
            XCTAssertEqual(bucketPtr[0].next, offset + 1)
        }
        
        let lastBucketPtr = storage._buffer.advanced(by: max(0, capacity2 - 1))
        
        XCTAssertEqual(lastBucketPtr[0].next, -1)
    }
    
    // MARK: Dequeue Reusable Bucket Offset
    func test_dequeueReusableBucketOffset_returnsReusableBucketOffset_ifThereIsAReusableBucketAvaialble() {
        let reusableBucketOffset = storage._dequeueReusableBucketOffset()
        
        XCTAssertEqual(reusableBucketOffset, 0)
        
        let bucketPtr = storage._buffer.advanced(by: reusableBucketOffset)
        
        XCTAssertEqual(bucketPtr[0].next, -1)
    }
    
    func test_dequeueReusableBucketOffset_doesNotGrowBuffer_ifAnyReusableBucketsAreAvaialble() {
        storage.push(0)
        _ = storage.pop()
        
        let capacity1 = storage._capacity
        
        XCTAssertNotEqual(storage._reuseHeadOffset, -1)
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity2 = storage._capacity
        
        XCTAssertEqual(capacity1, capacity2)
    }
    
    func test_dequeueReusableBucketOffset_growsBuffer_ifNoReusableBucketsAvaialble() {
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        let capacity1 = storage._capacity
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity2 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        XCTAssertNotEqual(capacity1, capacity2)
    }
    
    func test_dequeueReusableBucketOffset_movesReuseHeadOffsetToMinusOne_ifNoReusableBucketAfterDequeueingReusableBucket() {
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        let capacity1 = storage._capacity
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity2 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        XCTAssertNotEqual(capacity1, capacity2)
    }
    
    func test_dequeueReusableBucketOffset_movesReuseHeadOffsetToNewCapacityPlusOne_ifThereAreReusableBucketsAfterDequeueingReusableBucket() {
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        let capacity1 = storage._capacity
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity2 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        XCTAssertNotEqual(capacity1, capacity2)
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity3 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        XCTAssertNotEqual(capacity2, capacity3)
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity4 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, -1)
        
        XCTAssertNotEqual(capacity3, capacity4)
        
        _  = storage._dequeueReusableBucketOffset()
        
        let capacity5 = storage._capacity
        
        XCTAssertEqual(storage._reuseHeadOffset, capacity4 + 1)
        
        XCTAssertNotEqual(capacity4, capacity5)
    }
    
    // MARK: Enqueue Unused Bucket Offset
    func test_enqueueUnusedBucketOffset_enqueuesUnusedBucketOffset() {
        let reusableBucketOffset = storage._dequeueReusableBucketOffset()
        
        XCTAssertNotEqual(storage._reuseHeadOffset, reusableBucketOffset)
        
        storage._enqueueUnusedBucket(at: reusableBucketOffset)
        
        XCTAssertEqual(storage._reuseHeadOffset, reusableBucketOffset)
    }
    
    func test_enqueueUnusedBucketOffset_cleansBucketElement() {
        let reusableBucketOffset = storage._dequeueReusableBucketOffset()
        
        let bucketPtr = storage._buffer.advanced(by: reusableBucketOffset)
        bucketPtr[0].element = 1
        
        XCTAssertEqual(bucketPtr[0].element, 1)
        
        storage._enqueueUnusedBucket(at: reusableBucketOffset)
        
        XCTAssertEqual(bucketPtr[0].element, nil)
    }
    
    func test_enqueueUnusedBucketOffset_setsNextTo_reusableHeadeOffset() {
        let reusableBucketOffset = storage._dequeueReusableBucketOffset()
        
        let bucketPtr = storage._buffer.advanced(by: reusableBucketOffset)
        
        let oldReusableHeadOffset = storage._reuseHeadOffset
        
        XCTAssertEqual(bucketPtr[0].next, -1)
        
        storage._enqueueUnusedBucket(at: reusableBucketOffset)
        
        XCTAssertEqual(bucketPtr[0].next, oldReusableHeadOffset)
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
