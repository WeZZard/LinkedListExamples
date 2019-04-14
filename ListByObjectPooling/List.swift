//
//  List.swift
//  LinkedListExamples
//
//  Created on 2019/4/14.
//

import Foundation

// MARK: - List
public struct List<Element> {
    internal var _storage: _ListStorage<Element>
    
    public init() {
        _storage = .init()
    }
    
    public func peek() -> Element {
        return _storage.peek()
    }
    
    public mutating func push(_ element: Element) {
        _withDedicatedStorage { (storage) in
            storage.push(element)
        }
    }
    
    @discardableResult
    public mutating func pop() -> Element {
        return _withDedicatedStorage { (storage) in storage.pop() }
    }
    
    internal mutating func _withDedicatedStorage<R>(_ closure: (inout _ListStorage<Element>) -> R) -> R {
        if !isKnownUniquelyReferenced(&_storage) {
            _storage = _ListStorage(_storage)
        }
        return closure(&_storage)
    }
}

// MARK: - _ListStorage
internal class _ListStorage<Element> {
    internal var _headOffset: Int
    
    internal var _reuseHeadOffset: Int
    
    internal var _buffer: UnsafeMutablePointer<Bucket>!
    
    internal var _count: Int
    
    internal var _capacity: Int
    
    internal struct Bucket {
        /// Offset on the buffer.
        var next: Int
        
        var element: Element?
    }
    
    internal init() {
        _buffer = nil
        
        _headOffset = -1
        
        _reuseHeadOffset = -1
        
        _count = 0
        
        _capacity = 0
    }
    
    deinit {
        if let buffer = _buffer {
            buffer.deinitialize(count: _capacity)
            buffer.deallocate()
        }
    }
    
    internal init(_ storage: _ListStorage) {
        if let buffer = storage._buffer {
            _buffer = UnsafeMutablePointer<Bucket>.allocate(capacity: storage._capacity)
            _buffer.initialize(from: buffer, count: storage._capacity)
            _headOffset = storage._headOffset
            _reuseHeadOffset = storage._reuseHeadOffset
            _capacity = storage._capacity
            _count = storage._count
        } else {
            _buffer = nil
            _headOffset = -1
            _reuseHeadOffset = -1
            _count = 0
            _capacity = 0
        }
    }
    
    internal func _growBufferIfNeeded() {
        precondition(_reuseHeadOffset == -1)
        
        let oldBuffer = _buffer
        
        let oldCapacity = _capacity
        
        let newCapacity = max(1, _capacity + ((_capacity + 1) >> 1))
        
        let newBuffer = UnsafeMutablePointer<Bucket>.allocate(capacity: newCapacity)
        
        oldBuffer.map({newBuffer.initialize(from: $0, count: oldCapacity)})
        
        for offset in oldCapacity..<max(0, newCapacity - 1) {
            let bucket = newBuffer.advanced(by: offset)
            bucket[0].next = offset + 1
        }
        
        let newLastBucket = newBuffer.advanced(by: max(0, newCapacity - 1))
        newLastBucket[0].next = -1
        
        oldBuffer?.deinitialize(count: oldCapacity)
        oldBuffer?.deallocate()
        
        _buffer = newBuffer
        _reuseHeadOffset = oldCapacity
        _capacity = newCapacity
    }
    
    internal func _dequeueReusableBucketOffset() -> Int {
        if _reuseHeadOffset == -1 {
            _growBufferIfNeeded()
        }
        
        precondition(_reuseHeadOffset != -1)
        
        let reusableBucketIndex = _reuseHeadOffset
        let reusableBucketPtr = _withMutableBucket(at: reusableBucketIndex)
        
        _reuseHeadOffset = reusableBucketPtr[0].next
        reusableBucketPtr[0].next = -1
        
        return reusableBucketIndex
    }
    
    internal func _enqueueUnusedBucket(at offset: Int) {
        let unusedBucketPtr = _withMutableBucket(at: offset)
        unusedBucketPtr[0].element = nil
        unusedBucketPtr[0].next = _reuseHeadOffset
        _reuseHeadOffset = offset
    }
    
    internal func _withMutableBucket(at index: Int) -> UnsafeMutablePointer<Bucket> {
        precondition(index >= 0)
        return _buffer.advanced(by: index)
    }
    
    internal var count: Int {
        return _count
    }
    
    internal func peek() -> Element {
        precondition(_headOffset != -1, "Expecting list node.")
        
        let bucketPtr = _withMutableBucket(at: _headOffset)
        
        let element = bucketPtr[0].element
        
        precondition(element != nil, "Bad list node.")
        
        return element!
    }
    
    internal func push(_ element: Element) {
        let reusableBucketOffset = _dequeueReusableBucketOffset()
        
        let reusableBucketPtr = _withMutableBucket(at: reusableBucketOffset)
        
        reusableBucketPtr[0].element = element
        reusableBucketPtr[0].next = _headOffset
        
        _headOffset = reusableBucketOffset
        
        _count += 1
    }
    
    internal func pop() -> Element {
        precondition(_headOffset != -1, "Expecting list node.")
        
        let headBucketPtr = _withMutableBucket(at: _headOffset)
        
        let next = headBucketPtr[0].next
        let element = headBucketPtr[0].element
        
        precondition(element != nil, "Bad list node.")
        
        _enqueueUnusedBucket(at: _headOffset)
        
        _headOffset = next
        
        _count -= 1
        
        return element!
    }
}


extension List: Collection {
    public typealias Index = ListIndex
    
    public subscript(index: Index) -> Element {
        var offset = index._offset
        var ptrOffset = _storage._headOffset
        
        while offset > 0 {
            let nextBucketPtr = _storage._withMutableBucket(at: ptrOffset)
            ptrOffset = nextBucketPtr[0].next
            offset -= 1
        }
        
        let bucketPtr = _storage._withMutableBucket(at: ptrOffset)
        
        return bucketPtr[0].element!
    }
    
    public func index(after i: Index) -> Index {
        return Index(offset: i._offset + 1)
    }
    
    public var startIndex: Index { return .init(offset: 0) }
    
    public var endIndex: Index { return .init(offset: _storage.count) }
}


extension List: Sequence {
    public typealias Iterator = ListIterator<Element>
    
    public __consuming func makeIterator() -> Iterator {
        return Iterator(list: self)
    }
}


public struct ListIndex: Comparable, Hashable {
    internal let _offset: Int
    
    internal init(offset: Int) {
        _offset = offset
    }
    
    public static func < (lhs: ListIndex, rhs: ListIndex) -> Bool {
        return lhs._offset < rhs._offset
    }
}


public struct ListIterator<Element>: IteratorProtocol {
    internal var _storage: _ListStorage<Element>
    
    internal var _ptrOffset: Int
    
    public init(list: List<Element>) {
        _storage = list._storage
        _ptrOffset = _storage._headOffset
    }
    
    public mutating func next() -> Element? {
        guard _ptrOffset > -1 else { return nil }
        
        let bucketPtr = _storage._withMutableBucket(at: _ptrOffset)
        
        _ptrOffset = bucketPtr[0].next
        
        return bucketPtr[0].element
    }
}
