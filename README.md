RawData
=======

....is the Swift class to deal with collection of bytes. Attempt to build CollectionType type that works with collection of bytes. It is more or less `Array<UInt8>`

```swift
let raw = RawData([1,2,3,4,5,6]) // initialized with array of bytes
let byte = raw[0] 				 // first byte
print(raw.description) 			 // "<01020304 0506>"

raw.replaceRange(0...3, with: [10,9,8] // replace data
let shifted = raw << 3 	              // shift bytes left [4,5,6,0,0,0]
let or = shifted | [0,0,0,7,8,9]      // [4,5,6,7,8,9]


raw.append(10)						// [4,5,6,7,8,9,10]

```

License: MIT, Author: [Marcin Krzyżanowski](http://twitter.com/krzyzanowskim)
