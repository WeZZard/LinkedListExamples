//
//  List.swift
//  LinkedListExamples
//
//  Created on 2019/4/14.
//

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

internal class _ListNode<Element> {
    internal var element: Element?
    
    internal var next: Int = -1
    
    internal init(element: Element? = nil, next: Int = -1) {
        self.element = element
        self.next = next
    }
}

// MARK: - _ListStorage
internal class _ListStorage<Element> {
    internal var _headNodeIndex: Int
    
    internal var _nodes: [_ListNode<Element>]
    
    internal var _reusableIndices: Set<Int>
    
    internal var _count: Int
    
    internal init() {
        _headNodeIndex = -1
        
        _nodes = []
        
        _reusableIndices = []
        
        _count = 0
    }
    
    internal init(_ storage: _ListStorage) {
        _headNodeIndex = storage._headNodeIndex
        
        _nodes = storage._nodes.map({
            _ListNode(element: $0.element, next: $0.next)
        })
        
        _reusableIndices = storage._reusableIndices
        
        _count = storage._count
    }
    
    internal func _dequeueReusableNodeIndex() -> Int {
        if let anyIndex = _reusableIndices.first {
            _reusableIndices.remove(anyIndex)
            return anyIndex
        } else {
            let index = _nodes.endIndex
            let node = _ListNode<Element>()
            _nodes.append(node)
            return index
        }
    }
    
    internal func _enqueueUnusedNode(at index: Int) {
        _nodes[index].element = nil
        _nodes[index].next = -1
        _reusableIndices.insert(index)
    }
    
    internal var count: Int { return _count }
    
    internal func peek() -> Element {
        precondition(_headNodeIndex != -1, "Expecting list node.")
        
        let element = _nodes[_headNodeIndex].element
        
        precondition(element != nil, "Bad list node.")
        
        return element!
    }
    
    internal func push(_ element: Element) {
        let reusableBucketOffset = _dequeueReusableNodeIndex()
        
        _nodes[reusableBucketOffset].element = element
        _nodes[reusableBucketOffset].next = _headNodeIndex
        
        _headNodeIndex = reusableBucketOffset
        
        _count += 1
    }
    
    internal func pop() -> Element {
        precondition(_headNodeIndex != -1, "Expecting list node.")
        
        let next = _nodes[_headNodeIndex].next
        let element = _nodes[_headNodeIndex].element
        
        precondition(element != nil, "Bad list node.")
        
        _enqueueUnusedNode(at: _headNodeIndex)
        
        _headNodeIndex = next
        
        _count -= 1
        
        return element!
    }
}


extension List: Collection {
    public typealias Index = ListIndex
    
    public subscript(index: Index) -> Element {
        var offset = index._offset
        var ptrOffset = _storage._headNodeIndex
        while offset > 0 {
            let next = _storage._nodes[ptrOffset].next
            ptrOffset = next
            offset -= 1
        }
        
        let element = _storage._nodes[ptrOffset].element
        
        return element!
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
        _ptrOffset = _storage._headNodeIndex
    }
    
    public mutating func next() -> Element? {
        guard _ptrOffset > -1 else { return nil }
        
        let next = _storage._nodes[_ptrOffset].next
        let element = _storage._nodes[_ptrOffset].element
        
        _ptrOffset = next
        
        return element
    }
}
