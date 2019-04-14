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

class PerformanceBenchmark: XCTestCase {
    func testInsertionPerformance_ofListByObjectPooling() {
        measure {
            var list = ListByObjectPooling.List<Int>()
            
            for num in 0..<100000 {
                list.push(num)
            }
        }
    }
    
    func testInsertionPerformance_ofListByReferencePooling() {
        measure {
            var list = ListByReferencePooling.List<Int>()
            
            for num in 0..<100000 {
                list.push(num)
            }
        }
    }
    
    func testDeletionPerformance_ofListByObjectPooling() {
        var lists = Array(repeating: ListByObjectPooling.List<Int>(), count: 10)
        
        for index in 0..<10 {
            for num in 0..<100000 {
                lists[index].push(num)
            }
        }
        
        var index = 0
        measure {
            for _ in 0..<100000 {
                lists[index].pop()
            }
            index += 1
        }
    }
    
    func testDeletionPerformance_ofListByReferencePooling() {
        var lists = Array(repeating: ListByReferencePooling.List<Int>(), count: 10)
        
        for index in 0..<10 {
            for num in 0..<100000 {
                lists[index].push(num)
            }
        }
        
        var index = 0
        measure {
            for _ in 0..<100000 {
                lists[index].pop()
            }
            index += 1
        }
    }
}
