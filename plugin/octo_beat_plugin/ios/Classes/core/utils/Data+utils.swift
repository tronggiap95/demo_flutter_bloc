//
//  ByteUtils.swift
//  greenhouse-ver-02
//
//  Created by Cao Xuan Phong on 8/30/17.
//  Copyright © 2017 FioT. All rights reserved.
//

import UIKit

extension Data {
    enum ByteOrder {
        case BigEndian
        case LittleEndian
    }
    
    // MARK: Data Type Into Data
    func toByteBuffer() -> [UInt8] {
        return [UInt8](self)
    }
    
    static func byteArrayToData(_ array : [UInt8]) -> Data {
        return NSData(bytes: array as [UInt8], length: array.count) as Data
    }
    
    func toString() -> String? {
        return String(data: self, encoding: String.Encoding.utf8) as String?
    }
    
    func toHexString() -> [String] {
        let byteBuffer = toByteBuffer();
        var s = [String](repeating: "", count: byteBuffer.count)
        
        for i in stride(from: 0, to: byteBuffer.count, by: 1) {
            s[i] = "0x" +  String(format:"%.2x", byteBuffer[i] & 0xff);
        }
        
        return s
    }
    
    func convertDataToHexString(_ data: Data) -> [String] {
        let byteBuffer = [UInt8](data)
        var s = [String](repeating: "", count: byteBuffer.count)
        
        for i in stride(from: 0, to: byteBuffer.count, by: 1) {
            s[i] = "0x" +  String(format:"%.2x", byteBuffer[i] & 0xff);
        }
        
        return s
    }
    
    static func stringToData(_ str : String) -> Data {
        return str.data(using: .utf8)!
    }
    
    static func UInt32ToData(_ val : UInt32, byteOder : ByteOrder) -> Data {
        var value : UInt32 = val
        let buffer : Data!
        
        if (byteOder == .BigEndian) {
            value = val.bigEndian
        } else {
            value = val.littleEndian
        }
        
        buffer = Data(bytes: &value, count: MemoryLayout<UInt32>.size)
       // print (String(format: "buffer = %@", buffer as CVarArg))
        
        return buffer
    }
    
    func toUInt32(byteOrder : ByteOrder) -> UInt32 {
        
        let value : UInt32! = self.withUnsafeBytes { (ptr: UnsafePointer<UInt32>) -> UInt32 in
            return ptr.pointee
        }
        
        if (value != nil) {
            if (byteOrder == .BigEndian) {
                return value.bigEndian
            } else {
                return value.littleEndian
            }
        }
        
        return value
    }
    
    static func UInt64ToData(_ val : UInt64, byteOder : ByteOrder) -> Data {
        var value : UInt64 = val
        let buffer : Data!
        
        if (byteOder == .BigEndian) {
            value = val.bigEndian
        } else {
            value = val.littleEndian
        }
        
        buffer = Data(bytes: &value, count: MemoryLayout<UInt64>.size)
      //  print (String(format: "buffer = %@", buffer as CVarArg))
        
        return buffer
    }
    
    func toUInt64(byteOrder : ByteOrder) -> UInt64 {
        
        let value : UInt64! = self.withUnsafeBytes { (ptr: UnsafePointer<UInt64>) -> UInt64 in
            return ptr.pointee
        }
        
        if (value != nil) {
            if (byteOrder == .BigEndian) {
                return value.bigEndian
            } else {
                return value.littleEndian
            }
        }
        
        return value
    }
    
    static func UInt16ToData(_ val : UInt16, byteOder : ByteOrder) -> Data {
        var value : UInt16 = val
        let buffer : Data!
        
        if (byteOder == .BigEndian) {
            value = val.bigEndian
        } else {
            value = val.littleEndian
        }
        
        buffer = Data(bytes: &value, count: MemoryLayout<UInt16>.size)
      //  print (String(format: "buffer = %@", buffer as CVarArg))
        
        return buffer
    }
    
    func toUInt16(byteOrder : ByteOrder) -> UInt16 {
        
        let value : UInt16! = self.withUnsafeBytes { (ptr: UnsafePointer<UInt16>) -> UInt16 in
            return ptr.pointee
        }
        
        if (value != nil) {
            if (byteOrder == .BigEndian) {
                return value.bigEndian
            } else {
                return value.littleEndian
            }
        }
        
        return value
    }
    
    func toInt16(byteOrder : ByteOrder) -> Int16 {
           
           let value : Int16! = self.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
               return ptr.pointee
           }
           
           if (value != nil) {
               if (byteOrder == .BigEndian) {
                   return value.bigEndian
               } else {
                   return value.littleEndian
               }
           }
           
           return value
       }
    
    static func Float32ToData(_ val : Float32, byteOder : ByteOrder) -> Data {
        var value : Any!
        let buffer : Data!
        
        if (byteOder == .BigEndian) {
            value = CFConvertFloat32HostToSwapped(val).v
        } else {
            value = val
        }
        
        buffer = Data(bytes: &value, count: MemoryLayout<Float32>.size)
       // print (String(format: "buffer = %@", buffer as CVarArg))
        
        return buffer
    }
    
    func toFloat32(byteOrder : ByteOrder) -> Any {
        let value : Float32! = self.withUnsafeBytes { (ptr: UnsafePointer<Float32>) -> Float32 in
            return ptr.pointee
        }
        
        if (value != nil) {
            if (byteOrder == .BigEndian) {
                return Float32(bitPattern: CFConvertFloat32HostToSwapped(value).v)
            } else {
                return value
            }
        }
        
        return value
    }
    
    static func Float64ToData(_ val : Float64, byteOder : ByteOrder) -> Data {
        var value : Any!
        let buffer : Data!
        
        if (byteOder == .BigEndian) {
            value = CFConvertFloat64HostToSwapped(val).v
        } else {
            value = val
        }
        
        buffer = Data(bytes: &value, count: MemoryLayout<Float64>.size)
      //  print (String(format: "buffer = %@", buffer as CVarArg))
        
        return buffer
    }
    
    func toFloat64(byteOrder : ByteOrder) -> Any {
        let value : Float64! = self.withUnsafeBytes { (ptr: UnsafePointer<Float64>) -> Float64 in
            return ptr.pointee
        }
        
        if (value != nil) {
            if (byteOrder == .BigEndian) {
                return Float64(bitPattern: CFConvertFloat64HostToSwapped(value).v)
            } else {
                return value
            }
        }
        
        return value
    }
    
    func sub(in range: ClosedRange<Index>) -> Data? {
        let startPos = range.lowerBound
        let num = range.upperBound - range.lowerBound + 1
 
        if (startPos < 0 || num <= 0) {
            return nil
        }
        
        var endPos = 0
        
        if (startPos + num > self.count) {
            endPos = self.count
        } else {
            endPos = startPos + num
        }
        
        return subdata(in: startPos ..< endPos)
    }
    
    func subArray(in range: ClosedRange<Index>) -> Data? {
        let startPos = range.lowerBound
        var endPos = range.upperBound
        
        
        if (startPos < 0 || endPos <= 0) {
            return nil
        }
        
        if (endPos > self.count) {
            endPos = self.count
        }
        
        return subdata(in: startPos ..< endPos)
    }
    
    func merge(other : Data) -> Data {
        var v = self
        v.append(other)
        
        return v
    }
    
    func sameData(other : Data) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
    
    func contain(other : Data) -> Bool {
        if let _ = self.range(of: other) {
            return true
        }
        
        return false
    }
    
}

extension Sequence where Element: AdditiveArithmetic {
    /// Returns the total sum of all elements in the sequence
    func sum() -> Element { reduce(.zero, +) }
}

extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    func average() -> Element { isEmpty ? .zero : sum() / Element(count) }
    /// Returns the average of all elements in the array as Floating Point type
    func average<T: FloatingPoint>() -> T { isEmpty ? .zero : T(sum()) / T(count) }
}

extension Collection where Element: BinaryFloatingPoint {
    /// Returns the average of all elements in the array
    func average() -> Element { isEmpty ? .zero : Element(sum()) / Element(count) }
}
