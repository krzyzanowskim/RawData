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
    let pointer:UnsafeMutablePointer<Byte>
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
    
    func bytes() {
        
    }
    
    private func toHex() -> String {
        var hex = String()
        for var idx = 0; idx < count; ++idx {
            hex += String(format:"%02x", (pointer + idx).memory)
        }
        return hex
    }
}