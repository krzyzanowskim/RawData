//
//  RawData.swift
//  RawData
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

class RawData: CustomStringConvertible {
    typealias Byte = UInt8
    typealias Element = Byte
    
    let pointer:UnsafeMutablePointer<Element>
    let count:Int
    
    var description: String {
        return "<\(toHex())>"
    }
    
    init(count: Int) {
        self.pointer = UnsafeMutablePointer.alloc(count)
        self.count = count
    }
    
    deinit {
        pointer.dealloc(count)
    }
    
    private func toHex() -> String {
        var hex = String()
        for var idx = 0; idx < count; ++idx {
            hex += String(format:"%02x", (pointer + idx).memory)
        }
        return hex
    }
}

extension RawData: Indexable {
    typealias Index = Int
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        return max(count - 1,0)
    }
}

extension RawData: SequenceType {
    typealias Generator = AnyGenerator<Byte>
    
    func generate() -> Generator {
        var idx = 0
        return anyGenerator {
            let nextIdx = idx++
            
            if nextIdx > self.count - 1 {
                return nil
            }
            
            return self[nextIdx]
        }
    }
}

extension RawData: MutableCollectionType {
    subscript (position: Index) -> Generator.Element {
        get {
            if position < count {
                return (pointer + position).memory
            }
            return 0
        }
        set(newValue) {
            if position < count {
                (pointer + position).memory = newValue
            }
        }
    }
}
