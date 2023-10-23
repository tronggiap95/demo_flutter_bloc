//
//  Queue.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 29/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation
public struct Queue<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func removeAll() {
        array.removeAll()
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}
