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
        self.pointer = UnsafeMutablePointer<T>(calloc(count, sizeof(T)))
    }
    
    init(_ source: UnsafeMutablePointer<T>, count: Int) {
        self.init(count: count)
        self.pointer.initializeFrom(source, count: count)
    }
    
    private func dealloc() {
        pointer.destroy(count)
        pointer.dealloc(count)
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
        for var idx = 0; idx < ref.count; ++idx {
            str += String(format:"%02x", (ref.pointer + idx).memory)
        }
        return str
    }
    
    public required init() {
        ref = Pointer<Element>(count: 0)
    }
    
    public required init(_ count: Int) {
        ref = Pointer<Element>(count: count)
    }
    
    public required init(_ source: RawData) {
        ref = Pointer<Element>(source.ref.pointer, count: source.ref.count)
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
    
    public func copy() -> RawData {
        return RawData(self)
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

extension RawData: Equatable {
    // http://eternallyconfuzzled.com/tuts/algorithms/jsw_tut_hashing.aspx#elf
    private func elf_hash(len: UInt32) -> UInt32 {
        var h:UInt32 = 0, g:UInt32 = 0
        for (var i:UInt32 = 0; i < len; i++) {
            h = (h << 4) + UInt32(self[Int(i)])
            g = h & 0xf0000000
            if g != 0 {
                h ^= g >> 24
            }
            h &= g >> 24
        }
        return h
    }
}

public func ==(lhs: RawData, rhs: RawData) -> Bool {
    // CFHashCode check 80 bytes with ELF hash, so here we go
    return lhs.elf_hash(min(UInt32(lhs.count),80)) == rhs.elf_hash(min(UInt32(rhs.count),80))
}