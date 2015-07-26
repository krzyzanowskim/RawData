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
    
    typealias _Element = Element
    var startIndex: Index {
        return 0
    }
    var endIndex: Index {
        return max(count - 1,0)
    }
    subscript (position: Index) -> _Element {
        return 99
    }
}

extension RawData: CollectionType {
}

extension RawData: SequenceType {
    typealias Generator = AnyGenerator<Element>
    
    func generate() -> Generator {
        return anyGenerator {
            return 98
        }
    }
}
