//
//  RawData.swift
//  RawData
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

private struct Pointer<T> {
    let pointer:UnsafeMutablePointer<T>
    let count:Int
    
    init (count: Int) {
        self.count = count
        self.pointer = UnsafeMutablePointer<T>.alloc(count)
    }

    func dealloc() {
        pointer.dealloc(count)
        pointer.destroy()
    }
}

class RawData: CustomStringConvertible, ArrayLiteralConvertible, IntegerLiteralConvertible {
    typealias Byte = UInt8
    typealias Element = Byte
    
    private let ref:Pointer<Element>
    
    var description: String {
        var hex = self.hex
        for (i,j) in stride(from: 8, to: hex.utf8.count, by: 8).enumerate() {
            hex.insert(Character(" "), atIndex: advance(advance(hex.startIndex, j),i))
        }
        return "<\(hex)>"
    }
    
    var hex: String {
        var str = String()
        for var idx = 0; idx < count; ++idx {
            str += String(format:"%02x", (ref.pointer + idx).memory)
        }
        return str
    }
    
    required init() {
        ref = Pointer<Element>(count: 0)
    }
    
    required init(count: Int) {
        ref = Pointer<Element>(count: count)
    }
    
    required init(arrayLiteral elements: Element...) {
        ref = Pointer<Element>(count: elements.count)
        for (idx, element) in elements.enumerate() {
            (ref.pointer + idx).memory = element
        }
    }
    
    required init(integerLiteral value: UInt8) {
        ref = Pointer<Element>(count: 1)
        ref.pointer.memory = value
    }
    
    deinit {
        ref.dealloc()
    }
}

extension RawData: Indexable {
    typealias Index = Int
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        // The collection's "past the end" position.
        return ref.count == 0 ? 0 : max(ref.count,1)
    }
}

extension RawData: SequenceType {
    typealias Generator = AnyGenerator<Byte>
    
    func generate() -> Generator {
        var idx = 0
        return anyGenerator {
            let nextIdx = idx++
            
            
            if nextIdx > self.endIndex - 1 {
                return nil
            }
            
            return self[nextIdx]
        }
    }
}

extension RawData: MutableCollectionType, RangeReplaceableCollectionType {
    subscript (position: Index) -> Generator.Element {
        get {
            if position >= endIndex {
                fatalError("index out of range")
            }
            
            return (ref.pointer + position).memory
        }
        set(newValue) {
            if position >= endIndex {
                fatalError("index out of range")
            }
            
            (ref.pointer + position).memory = newValue
        }
    }
    
    func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        var generator = newElements.generate()
        for var idx = subRange.startIndex; idx < subRange.endIndex - 1; idx++ {
            
            guard let nextElement = generator.next() else {
                break
            }
            
            (ref.pointer + idx).memory = nextElement
        }
    }
}
