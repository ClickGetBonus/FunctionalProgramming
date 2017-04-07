//: Playground - noun: a place where people can play

import UIKit


let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]

//不能保证字典中肯定存在Madrid这个键值
//let madridPopulation: Int = cities["Madrid"]


let madridPopulation: Int? = cities["Madrid"]
//
//if madridPopulation != nil {
//    print("The population of Madrid is \(madridPopulation! * 1000)")
//} else {
//    print("Unkone city: Madrid")
//}

//可选绑定的解包方式
if let madridPopulation = cities["Madrid"] {
    print("The population of Madrid is \(madridPopulation * 1000)")
} else {
    print("Unkone city: Madrid")
}

//使用 ?? 解包
infix operator ?? : group
precedencegroup group {
    associativity : right
}



//func ??<T>(optional: T?, defaultValue: T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue
//    }
//}
//let string: String? = "value"
//let string2 = string ?? "no value"



////减少了defaultValue的运算
//func ??<T>(optional: T?, defaultValue: () -> T) -> T {
//    if let x = optional {
//        return x
//    } else {
//        return defaultValue()
//    }
//}
//
//
//let string: String? = nil
//let string2 = string ?? { "no value"}


//避免创建显示闭包
func ??<T>(optional: T?, defaultValue: @autoclosure () -> T) -> T {
    if let x = optional {
        return x
    } else {
        return defaultValue()
    }
}

let string: String? = nil
string ?? "no Value"



// 4.2 玩转可选型


//可选值链
struct Order {
    let orderNumber: Int
    let person: Person?
}

struct Person {
    let name: String
    let address: Address?
}

struct Address {
    let streetName: String
    let city: String
    let state: String?
}

//显式解包
let order = Order(orderNumber: 10, person: Person(name: "name", address: Address(streetName: "streetName", city: "city", state: "state")))
order.person!.address!.state! //值缺失时会导致异常

//可选绑定更安全
if let myPerson = order.person {
    if let myAddress = myPerson.address {
        if let myState = myAddress.state {
            
        }
    }
}  //太过于繁琐

//使用可选链
if let myState = order.person?.address?.state {
    
} else {
    
}




//使用switch语言与optional搭配使用
switch madridPopulation {
case 0?: print("Nobody in Madrid")
case (1..<1000)?: print("Less than a million in Madrid")
case .some(let x): print("\(x) people in Madrid")
case .none: print("We don't know about Madrid")
}


//使用guard
func populationDescriptionForCity(city: String) -> String? {
    guard let population = cities[city] else { return nil }
    return "The population of Madrid is \(population * 1000)"
}
print(populationDescriptionForCity(city: "Madrid"))






//可选映射

func incrementOptional(optional: Int?) -> Int? {
    guard let x = optional else { return nil }
    return x + 1
}

extension Optional {
    
    func map<U>(transform: (Wrapped) -> U) -> U? {
        guard let x = self else { return nil }
        return transform(x)
    }
}


//再谈可选绑定
let x: Int? = 3
let y: Int? = nil
//不被编译器接受, Int? 类型并没有定义+方法
//let z: Int? = x + y

func addOptions(optionalX: Int?, optionalY: Int?) -> Int? {
    if let x = optionalX {
        if let y = optionalY {
            return x + y
        }
    }
    
    return nil
}

func addOptionals2(optionalX: Int?, optionalY: Int?) -> Int? {
    if let x = optionalX, let y = optionalY {
        return x + y
    }
    
    return nil
}

func addOptionals3(optionalX: Int?, optionalY: Int?) -> Int? {
    guard let x = optionalX, let y = optionalY else {
        return nil
    }
    
    return x + y
}


let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels"
]

func populationOfCapital(country: String) -> Int? {
    guard let capital = capitals[country], let population = cities[capital]
        else { return nil }
    return population * 1000
}

//extension Optional {
//    func flatMap<U>(f: (Wrapped) -> U?) -> U? {
//        guard let x = self else { return nil }
//        return f(x)
//    }
//}


func addOptionals4(optionalX: Int?, optionalY: Int?) -> Int? {
    
    return optionalX.flatMap { x in
        optionalY.flatMap { y in
            return x + y
        }
    }
}

func populationOfCapital2(country: String) -> Int? {
    return capitals[country].flatMap { capital in
        cities[capital].flatMap { population in
            return population * 1000
        }
    }
}


//链式调用
func populationOfCapital3(country: String) -> Int? {
    return capitals[country].flatMap { capital in
        return cities[capital]
        }.flatMap { population in
            return population * 1000
    }
}






