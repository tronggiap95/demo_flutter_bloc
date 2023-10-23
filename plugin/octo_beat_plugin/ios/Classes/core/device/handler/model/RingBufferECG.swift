//
//  RingBufferECG.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 9/24/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class RingBufferECG {
    private var queue: RingBuffer<ECGData>?
//    private var queueCh1: RingBuffer<Float>?
//    private var queueCh2: RingBuffer<Float>?
//    private var queueCh3: RingBuffer<Float>?
    
    var size: Int {
        return queue?.availableSpaceForReading ?? 0
    }
    
//    var ch1Size: Int {
//        return queueCh1?.availableSpaceForReading ?? 0
//    }
//
//    var ch2Size: Int {
//        return queueCh2?.availableSpaceForReading ?? 0
//    }
//
//    var ch3Size: Int {
//        return queueCh3?.availableSpaceForReading ?? 0
//    }
    
    func initQueues() {
        queue = RingBuffer<ECGData>(count: 1500)
//        queueCh1 = RingBuffer<Float>(count: 3000)
//        queueCh2 = RingBuffer<Float>(count: 3000)
//        queueCh3 = RingBuffer<Float>(count: 3000)
    }
    
    func clear() {
        queue = nil
//        queueCh1 = nil
//        queueCh2 = nil
//        queueCh3 = nil
    }
    
    func write(data: ECGData, gain: Double) {
        var value = ECGData()
        
        if let ch3 = data.ch3 {
//            queueCh3?.write(ch3)
            value.ch3 = (ch3 / Float(gain))
        }
        
        if let ch2 = data.ch2 {
//            queueCh2?.write(ch2)
            value.ch2 = (ch2 / Float(gain))
        }
        
        if let ch1 = data.ch1 {
//            queueCh1?.write(ch1)
            value.ch1 = (ch1 / Float(gain))
        }
        
        queue?.write(value)
    }
    
    func read(count: Int) -> [ECGData?]? {
        if count < queue?.availableSpaceForReading ?? 0{
            var list = [ECGData?]()
            for _ in 0..<count {
                list.append(queue?.read())
            }
            return list
        }
        return nil
    }
    
//    func readCh1(count: Int) -> [Float]? {
//        if count < queueCh1?.availableSpaceForReading ?? 0 {
//            var array = [Float]()
//            for _ in 0..<count {
//                if let value = queueCh1?.read() {
//                    array.append(value)
//                } else {
//                    return nil
//                }
//            }
//            return array
//        }
//        return nil
//    }
//
//    func readCh2(count: Int) -> [Float]? {
//        if count < queueCh2?.availableSpaceForReading ?? 0{
//            var array = [Float]()
//            for _ in 0..<count {
//                if let value = queueCh2?.read() {
//                    array.append(value)
//                } else {
//                    return nil
//                }
//            }
//            return array
//        }
//        return nil
//    }
//
//    func readCh3(count: Int) -> [Float]? {
//        if count < queueCh3?.availableSpaceForReading ?? 0 {
//            var array = [Float]()
//            for _ in 0..<count {
//                if let value = queueCh3?.read() {
//                    array.append(value)
//                } else {
//                    return nil
//                }
//            }
//            return array
//        }
//        return nil
//    }
    
}
