//: Playground - noun: a place where people can play

import UIKit

let numberOfInterations: Int = 100

//验证加法是否满足交换律
func plusIsCommutative(x: Int, y: Int) -> Bool {
    return x + y == y + x
}

//check实现

//protocol Arbitrary {
//    static func arbitrary() -> Self
//}
//
//extension Int: Arbitrary {
//    static func arbitrary() -> Int {
//        return Int(arc4random())
//    }
//}
//
//Int.arbitrary()
//
//extension Character: Arbitrary {
//    static func arbitrary() -> Character {
//        return Character(UnicodeScalar(Int.randow(from: 65, to: 90))!)
//    }
//}
//
func tabulate<A>(times: Int, transform: (Int) -> A) -> [A] {
    return (0..<times).map(transform)
}
//
//extension Int {
//    static func randow(from: Int, to: Int) -> Int {
//        return from + (Int(arc4random()) % (to - from))
//    }
//}
//
//extension String: Arbitrary {
//    static func arbitrary() -> String {
//        let randomLength = Int.randow(from: 0, to: 20)
//        let randomCharaters = tabulate(times: randomLength) { _ in
//            Character.arbitrary()
//        }
//        return String(randomCharaters)
//        
//    }
//}
//
//let z: Character = Character(UnicodeScalar(90))
//let j: Character = Character(UnicodeScalar(74))
//let string: String = String([z, j])
//
//String.arbitrary()
//
//
//
//
////使用上面的工具编写check函数
//
//
//func check1<A: Arbitrary>(message: String, _ property: (A) -> Bool) -> () {
//    for _ in 0 ..< numberOfInterations {
//        let value = A.arbitrary()
//        guard property(value) else {
//            print("\"\(message)\" doesn't hold: \(value)")
//            return
//        }
//        
//    }
//    
//    print("\"\(message)\" passed \(numberOfInterations) test")
//}
//
////测试check函数
//extension CGSize {
//    var area: CGFloat {
//        return width * height
//    }
//}
//
//extension CGSize: Arbitrary {
//    static func arbitrary() -> CGSize {
//        return CGSize(width: Int.randow(from: -10, to: 100),
//                      height: Int.randow(from: 0, to: 200))
//    }
//}
//
//check1(message: "Area Should be at least 0") { (size: CGSize) in size.area >= 0}




//5.2 缩小范围
//check1(message: "Every string starts with Hello") { (s: String) in s.hasPrefix("Hello") }

protocol Smaller {
    func smaller() -> Self?
}

extension Int: Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self / 2
    }
}

100.smaller()

extension String: Smaller {
    func smaller() -> String? {
        return isEmpty ? nil : String(self.characters.dropFirst())
    }
}
//重新定义Arbitrary协议以扩展Smaller协议
protocol Arbitrary: Smaller {
    static func arbitrary() -> Self
}

//反复缩小范围
func iterateWhile<A>(condition: (A) -> Bool, initial: A, next: (A) -> A?) -> A {
    if let x = next(initial) , condition(x) {
        return iterateWhile(condition: condition, initial: x, next: next)
    }
    return initial
}

func check2<A: Arbitrary>(message: String, _ property: (A) -> Bool) -> () {
    for _ in 0..<numberOfInterations {
        let value = A.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: { !property($0) }, initial: value) {
                $0.smaller()
            }
            print("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    
    print("\"\(message)\" passed \(numberOfInterations) tests")
}

extension Int: Arbitrary {
    internal static func arbitrary() -> Int {
        return Int(arc4random()%1000)
    }
}


check2(message: "number > 10") { (x: Int) in x > 10}



/*
 5.3 随机数组
 */

// 函数式版本的快速排序
func qsort( _ array: [Int]) -> [Int] {
    
    var array = array
    
    if array.isEmpty { return [] }
    let pivot = array.remove(at: 0)
    let lesser = array.filter { $0 < pivot }
    let greater = array.filter { $0 >= pivot }
    
    //无法使用 qsort(leser) + [pivot] + qsort(greater) 的表达式, 可能是3.0的更改或者是BUG
    let pivotArray = [pivot]
    return qsort(lesser) + pivotArray + qsort(greater)
}
//let a: Int = 1
//let b: Int = 2
//let c: Int = 3
//
//let aArray: Array = [a]
//let bArray: Array = [b]
//let cArray: Array = [c]
//
//aArray + bArray + cArray
////[a] + [b] + [c]


qsort([3,1,4,2,8])

extension Array: Smaller {
    
    internal func smaller() -> Array? {
        guard !isEmpty else { return nil }
        return Array(dropFirst())
    }
}

extension Array where Element: Arbitrary {
    
    static func arbitrary() -> Array<Element> {
        let randomLength = Int(arc4random()%50)
        return tabulate(times: randomLength) { _ in Element.arbitrary() }
    }
}


// 只有Array的每一项都遵循Arbitrary协议, 数组本身才会遵循Arbitrary协议, 所以没法这样使用check2
//check2(message: "qsort should begave like sort") { (x: [Int]) -> Bool in
//    return qsort(x) == x.sorted(by: <)
//}

// 修改check2函数
// check2<A>本身的要求是类型A遵循Arbitrary协议,  我们将放弃这个需求, 改为必要的函数smaller和arbitrary作为参数传入

//定义一个包含两个所需函数的辅助结构体
struct ArbitraryInstance<T> {
    let arbitrary: () -> T
    let smaller: (T) -> T?
}

//定义checkHelper, 为原来的Check函数再次封装, 定义一个把arbitrary和smaller都作为参数传递的方法, 使得即使是不遵循Arbitrary协议的类型都可以使用这个check方法
func checkHelper<A>(_ arbitraryInstance: ArbitraryInstance<A>,
                 _ property: (A) -> Bool, _ message: String) -> () {
    
    for _ in 0..<numberOfInterations {
        let value = arbitraryInstance.arbitrary()
        guard property(value) else {
            let smallerValue = iterateWhile(condition: { !property($0) }, initial: value, next: arbitraryInstance.smaller )
            print("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
        
    }
    
    print("\"\(message)\" passed \(numberOfInterations) tests.")
}


func check3<X: Arbitrary>(message: String, property: (X) -> Bool) -> () {
    let instance = ArbitraryInstance(arbitrary: X.arbitrary, smaller: { $0.smaller() })
    checkHelper(instance, property, message)
}


//为数组重载check函数并构造自己所需要的ArbitraryInstance结构体
func check3<X: Arbitrary>(message: String, _ property: ([X]) -> Bool) -> () {
    let instance = ArbitraryInstance(arbitrary: [X].arbitrary, smaller: { (x: [X]) in x.smaller() })
    checkHelper(instance, property, message)
}


check3(message: "qsort should begave like sort") { (x: [Int]) in
    return qsort(x) == x.sorted(by: <)
}
