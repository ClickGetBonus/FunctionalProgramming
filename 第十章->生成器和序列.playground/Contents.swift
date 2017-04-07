//: Playground - noun: a place where people can play

import UIKit


let xs1: [Int] = []

for x in xs1 {
    // do something with x
}

/*
 如果想要用不同的顺序来对数组进行遍历的话, 生成器就可能派上用场
 */

protocol GeneratorType {
    associatedtype Element
    func next() -> Element?
}

class CountdownGenerator: GeneratorType {
    var element: Int
    
    init<T>(array: [T]) {
        self.element = array.count - 1
    }
    
    func next() -> Int? {
        if self.element < 0 {
            return nil
        } else {
            self.element -= 1
            return element+1
        }
    }
    
}


let xs = ["A", "B", "C"]

let generator = CountdownGenerator(array: xs)
while let i = generator.next() {
    print("Element \(i) of the array is \(xs[i])")
//    print("Element \(i) of the array is \(xs[i])")

}



//定义一个生成"无数个"2的幂值得生成器(知道NSDecimalNumber溢出)
class PowerGenerator: GeneratorType {
    var power: NSDecimalNumber = 1
    let two: NSDecimalNumber = 2
    
    func next() -> NSDecimalNumber? {
        power = power.multiplying(by: two)
        return power
    }
}


//希望在2的幂值中搜索一些有趣的值
extension PowerGenerator {
    func findPower(predicate: (NSDecimalNumber) -> Bool) -> NSDecimalNumber {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return 0
    }
}

//计算2的幂值中大于1000的最小值
let x = PowerGenerator().findPower { $0.intValue > 1000 }
x


let documentPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/123"
print(documentPaths)

//生成一组字符串的生成器
class FileLinesGenerator: GeneratorType {
    typealias Element = String
    
    var lines: [String] = []
    
    init(fileName: String) throws {
        let contents: String = try String(contentsOfFile: fileName)
        contents
        let newLine = NSCharacterSet.newlines
        newLine
        lines = contents.components(separatedBy: newLine)
    }
    
    func next() -> String? {
        guard !lines.isEmpty else { return nil }
        let nextLine = lines.remove(at: 0)
        return nextLine
    }
}

do {
    let generator = try FileLinesGenerator(fileName: documentPaths)
    generator.lines
    while let x =  generator.next() {
        print(x)
    }
} catch {
    print("Error")
}


//泛型版本生成器
extension GeneratorType {
    mutating func find(predicate: (Element) -> Bool) -> Element? {
        while let x = next() {
            if predicate(x) {
                return x
            }
        }
        return nil
    }
}


class LimitGenerator<G: GeneratorType>: GeneratorType {
    var limit = 0
    var generator: G
    
    init(limit: Int, generator: G) {
        self.limit = limit
        self.generator = generator
    }
    
    func next() -> G.Element? {
        guard limit >= 0 else { return nil }
        limit -= 1
        return generator.next()
    }
}



