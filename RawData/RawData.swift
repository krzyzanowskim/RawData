//
//  RawData.swift
//  RawData
//
//  Created by Marcin Krzyzanowski on 26/07/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

private struct Pointer<T: IntegerLiteralConvertible> {
    private let pointer:UnsafeMutablePointer<T>
    private let count:Int
    
    init (count: Int) {
        self.count = count
        self.pointer = UnsafeMutablePointer<T>.alloc(count)
        for i in 0..<count {
            (self.pointer+i).initialize(0)
        }
    }

    func dealloc() {
        pointer.dealloc(count)
        pointer.destroy(count)
    }
}

public class RawData: CustomStringConvertible, ArrayLiteralConvertible, IntegerLiteralConvertible {
    public typealias Byte = UInt8
    public typealias Element = Byte // Byte
    
    private let ref:Pointer<Element>
    
    public var description: String {
        var hex = self.hex
        for (i,j) in stride(from: 8, to: hex.utf8.count, by: 8).enumerate() {
            hex.insert(Character(" "), atIndex: advance(advance(hex.startIndex, j),i))
        }
        return "<\(hex)>"
    }
    
    public var hex: String {
        var str = String()
        for var idx = 0; idx < count; ++idx {
            str += String(format:"%02x", (ref.pointer + idx).memory)
        }
        return str
    }
    
    public required init() {
        ref = Pointer<Element>(count: 0)
    }
    
    public required init(count: Int) {
        ref = Pointer<Element>(count: count)
    }
    
    public required init(arrayLiteral elements: Element...) {
        ref = Pointer<Element>(count: elements.count)
        for (idx, element) in elements.enumerate() {
            (ref.pointer + idx).memory = element
        }
    }
    
    public required init(integerLiteral value: UInt8) {
        ref = Pointer<Element>(count: 1)
        ref.pointer.memory = value
    }
    
    deinit {
        ref.dealloc()
    }
}

extension RawData: Indexable {
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }
    
    public var endIndex: Index {
        // The collection's "past the end" position.
        return ref.count == 0 ? 0 : max(ref.count,1)
    }
}

extension RawData: SequenceType {
    public typealias Generator = AnyGenerator<Byte>
    
    public func generate() -> Generator {
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
    public subscript (position: Index) -> Generator.Element {
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
    
    public func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Index>, with newElements: C) {
        var generator = newElements.generate()
        for var idx = subRange.startIndex; idx < subRange.endIndex - 1; idx++ {
            
            guard let nextElement = generator.next() else {
                break
            }
            
            (ref.pointer + idx).memory = nextElement
        }
    }
}
