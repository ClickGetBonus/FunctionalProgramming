//: Playground - noun: a place where people can play

import UIKit

/*
 第三章 Map, Filter , Reduce
 */


//简化链

//数组内自增1
func incrementArray(xs: [Int]) -> [Int] {
    var newArray: [Int] = []
    for value in xs {
        newArray.append(value+1)
    }
    
    return newArray
}
incrementArray(xs: [1,3,5,2])


//通用化
func computeInArray(xs: [Int], transform: (Int) -> Int) -> [Int] {
    var newArray: [Int] = []
    for value in xs {
        newArray.append(transform(value))
    }
    return newArray
}

let newArray = computeInArray(xs: [1,2,3,4], transform: { $0*2 })
newArray

//更通用
func computeInArray<T>(xs: [Int], transform: (Int) -> T) -> [T] {
    var result: [T] = []
    for value in xs {
        result.append(transform(value))
    }
    return result
}

//更进一步
func computeInArray<Element, T>(xs: [Element], transform: (Element) -> T) -> [T] {
    var result: [T] = []
    for value in xs {
        result.append(transform(value))
    }
    return result
}

//按照swift的管理变化
extension Array {
    func map<T>(transform: (Element) -> T) -> [T] {
        var result: [T] = []
        for value in self {
            result.append(transform(value))
        }
        return result
    }
}




//Filter
extension Array {
    func filter(includeElement: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self where includeElement(x) {
            result.append(x)
        }
        return result
    }
}

let newArray2 = [4,2,1,5,3].filter(includeElement: {return $0<4})
newArray2



//Reduce
//Normal Implement
func sum(xs: [Int]) -> Int {
    var result: Int = 0
    for x in xs {
        result += x
    }
    return result
}

func product(xs: [Int]) -> Int {
    var result: Int = 0
    for x in xs {
        result *= x
    }
    return result
}

func concatenate(xs: [String]) -> String{
    var result: String = ""
    for x in xs {
        result += x
    }
    return result
}

concatenate(xs: ["111", "aa"])


//通用
extension Array {
    func reduce<T>(initial: T, combine: (T, Element) -> T) -> T {
        var result: T = initial
        for x in self {
            result = combine(result, x)
        }
        
        return result
    }
}

//用reduce定义之前的函数
func sumUsingReduce(xs: [Int]) -> Int {
    return xs.reduce(0){ $0 + $1 }
}

func productUsingReduce(xs: [Int]) -> Int {
    return xs.reduce(initial: 0, combine: *)
}

func concatUsingReduce(xs: [String]) -> String {
    return xs.reduce(initial: "", combine: +)
}



//合并数组
func flatten<T>(xss: [[T]]) -> [T] {
    var result: [T] = []
    for xs in xss {
        result += xs
    }
    return result
}

//用Reduce
func flattenUsingReduce<T>(xss: [[T]]) -> [T] {
    return xss.reduce(initial: [], combine: +)
}


//用Reduce定义map和filter函数
func mapUsingReduce<Element,T>(xs: [Element],transform: (Element) -> T) -> [T] {
    return xs.reduce([]){
        result, x in
        return result + [transform(x)]
    }
}

func filterUsingReduce<Element>(xs: [Element], includeElement: (Element) -> Bool) -> [Element] {
    return xs.reduce([]){
        result, x in
        return includeElement(x) ? result + [x] : result
    }
}

let newArray3 = mapUsingReduce(xs: [4,2,3,6,3,1,23], transform: { $0+1 })
newArray3

let newArray4 = filterUsingReduce(xs: [4,2,5,7,8,3,8], includeElement: { $0<5 })
newArray4








// 3.4 实际应用
struct City {
    let name: String
    let population: Int
}

let paris = City(name: "Paris", population: 2241)
let madrid = City(name: "Madrid", population: 3165)
let amsterdam = City(name: "Amsterdam", population: 827)
let berlin = City(name: "Berlin", population: 3562)
let citys = [paris, madrid, amsterdam, berlin]

extension City {
    
    func cityByScalingPopulation() -> City {
        return City(name: name, population: population * 1000)
    }
}

citys.filter{ $0.population > 1000 }
    .map{ $0.cityByScalingPopulation() }
    .reduce("City: Population"){
        result, x in
        return result + "\n" + "\(x.name): \(x.population)"
}


// 3.5 泛型和Any类型

//区别 
func noOp<T>(x: T) -> T {
    return x
}

func noOpAny(x: Any) -> Any {
    return x //输入值和输出值可以是任意类型, 可以不一样
}

func noOpAnyWrong(x: Any) -> Any {
    return 0
}

//第二章封装CoreImage定义的>>>运算符运用泛型

precedencegroup group {
    associativity : left
}
infix operator >>> : group

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { x in g(f(x)) }
}



func curry<A, B, C>(f: @escaping (A, B) -> C) -> (A) -> ((B) -> C) {
    return { x in { y in f(x, y) } }
}



