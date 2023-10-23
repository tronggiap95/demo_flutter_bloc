//
//  BufferECG.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 18/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class BufferECG {
    private var queue = SynchronizedArray<ECGData>()
    private var queueCh1 = SynchronizedArray<Float>()
    private var queueCh2 = SynchronizedArray<Float>()
    private var queueCh3 = SynchronizedArray<Float>()
    
    var size: Int {
        return queue.count
    }
    
    var ch1Size: Int {
        return queueCh1.count
    }
    
    var ch2Size: Int {
        return queueCh2.count
    }
    
    var ch3Size: Int {
        return queueCh3.count
    }
    
    func clear() {
        queue.removeAll()
        queueCh1.removeAll()
        queueCh2.removeAll()
        queueCh3.removeAll()
    }
    
    func write(data: ECGData, gain: Double) {
        var value = ECGData()
        
        if let ch3 = data.ch3 {
            queueCh3.append(ch3)
            value.ch3 = (ch3 / Float(gain))
        }
        
        if let ch2 = data.ch2 {
            queueCh2.append(ch2)
            value.ch2 = (ch2 / Float(gain))
        }
        
        if let ch1 = data.ch1 {
            queueCh1.append(ch1)
            value.ch1 = (ch1 / Float(gain))
        }
        queue.append(value)
    }
    
    func read(count: Int) -> [ECGData?]? {
        if count < queue.count {
            var list = [ECGData?]()
            for _ in 0..<count {
                list.append(queue.first)
            }
            return list
        }
        return nil
    }
    
    func readCh1(count: Int) -> [Float]? {
        if count < queueCh1.count {
            var array = [Float]()
            for _ in 0..<count {
               if let value = queueCh1.first {
                    array.append(value)
                } else {
                    return nil
                }
            }
            return array
        }
        return nil
    }
    
    func readCh2(count: Int) -> [Float]? {
        if count < queueCh2.count {
            var array = [Float]()
            for _ in 0..<count {
                if let value = queueCh2.first {
                    array.append(value)
                } else {
                    return nil
                }
            }
            return array
        }
        return nil
    }
    
    func readCh3(count: Int) -> [Float]? {
        if count < queueCh3.count {
            var array = [Float]()
            for _ in 0..<count {
               if let value = queueCh3.first {
                    array.append(value)
                } else {
                    return nil
                }
            }
            return array
        }
        return nil
    }
    
}
