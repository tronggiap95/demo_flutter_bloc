//
//  ConcurrentArray.swift
//  TestThread
//
//  Created by Manh Tran on 11/2/19.
//  Copyright © 2019 fiot.vn. All rights reserved.
//

import Foundation

class ConcurrentArray<T> {
    private var dataSource: Array<T>
    
    init() {
        self.dataSource = [T]()
    }
    
    func append(_ element: T) {
        synchronized(self) {
            dataSource.append(element)
        }
    }
    
    func removeLast() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeLast()
        }
    }
    
    func removeFirst() -> T {
        return synchronized(self) { () -> T in
            return dataSource.removeFirst()
        }
    }
    
    func insertFirst(_ element: T) {
        return synchronized(self) {
            dataSource.insert(element, at: 0)
        }
    }
    
    func removeAtIndex(_ index: Int) -> T {
        return synchronized(self) { () -> T in
            return dataSource.remove(at: index)
        }
    }
    
    func removeAll(_ keepCapacity: Bool = false) {
        synchronized(self) {
            dataSource.removeAll(keepingCapacity: keepCapacity)
        }
    }
    
    func count() -> Int {
        return synchronized(self) { () -> Int in
            return dataSource.count
        }
    }
}
