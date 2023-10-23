//
//  TestFile.swift
//  TestThread
//
//  Created by Manh Tran on 11/2/19.
//  Copyright © 2019 fiot.vn. All rights reserved.
//

import Foundation
enum MyError: Error {
    case runtimeError(String)
}
class BlockingQueue<Element> {
    
    private var dataSource: ConcurrentArray<Element>
    
    private let dataSemaphore: DispatchSemaphore
    
    
    
    init() {
        
        dataSource = ConcurrentArray<Element>()
        
        dataSemaphore = DispatchSemaphore(value: 0)
        
    }
    
    
    
    func add(_ e: Element) {
        dataSource.append(e)
        // New data available.
        dataSemaphore.signal()
        
    }
    
    func removeAll() {
        dataSource.removeAll()
    }
    
    func insertFirst(_ e: Element){
        dataSource.insertFirst(e)
        dataSemaphore.signal()
    }
    
    func count() -> Int{
        return dataSource.count()
    }
    
    func take(_ timeout: TimeInterval? = nil) throws -> Element {
        
        let t: DispatchTime
        
        if let timeout = timeout {
            
            t = DispatchTime.now() + Double(Int64(timeout * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            
        } else {
            
            t = DispatchTime.distantFuture
            
        }
        
        dataSemaphore.wait(timeout: t)
        // This will throw error if there's no element.
        
        if(dataSource.count() <= 0) {
            throw MyError.runtimeError("No data")
        }
        
        return dataSource.removeFirst()
    }
}
