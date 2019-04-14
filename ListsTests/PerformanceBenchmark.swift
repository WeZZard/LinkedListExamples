//
//  PerformanceBenchmark.swift
//  LinkedListExamples
//
//  Created on 2019/4/14.
//

import XCTest

@testable
import ListByObjectPooling

@testable
import ListByReferencePooling

let amount = 1000000

class PerformanceBenchmark: XCTestCase {
    func testInsertionPerformance_ofArray() {
        measure {
            var array = ContiguousArray<Int>()
            
            for num in 0..<amount {
                array.append(num)
            }
        }
    }
    
    func testInsertionPerformance_ofListByObjectPooling() {
        measure {
            var list = ListByObjectPooling.List<Int>()
            
            for num in 0..<amount {
                list.push(num)
            }
        }
    }
    
    func testInsertionPerformance_ofListByReferencePooling() {
        measure {
            var list = ListByReferencePooling.List<Int>()
            
            for num in 0..<amount {
                list.push(num)
            }
        }
    }
    
    func testDeletionPerformance_ofArray() {
        var arrays = Array(repeating: ContiguousArray<Int>(), count: 10)
        
        for index in 0..<10 {
            for num in 0..<amount {
                arrays[index].append(num)
            }
        }
        
        var index = 0
        measure {
            for _ in 0..<amount {
                arrays[index].removeLast()
            }
            index += 1
        }
    }
    
    func testDeletionPerformance_ofListByObjectPooling() {
        var lists = Array(repeating: ListByObjectPooling.List<Int>(), count: 10)
        
        for index in 0..<10 {
            for num in 0..<amount {
                lists[index].push(num)
            }
        }
        
        var index = 0
        measure {
            for _ in 0..<amount {
                lists[index].pop()
            }
            index += 1
        }
    }
    
    func testDeletionPerformance_ofListByReferencePooling() {
        var lists = Array(repeating: ListByReferencePooling.List<Int>(), count: 10)
        
        for index in 0..<10 {
            for num in 0..<amount {
                lists[index].push(num)
            }
        }
        
        var index = 0
        measure {
            for _ in 0..<amount {
                lists[index].pop()
            }
            index += 1
        }
    }
}
