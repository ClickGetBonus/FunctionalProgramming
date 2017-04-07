//: Playground - noun: a place where people can play

import UIKit

//enum NSStringEncoding {
//    NSASCIIStringEncoding = 1,
//    NSNEXTSTEPStringEncoding = 2,
//    NSJapaneseEUCStringEncoding = 3,
//    NSUTF8StringEncoding = 4
//}

//在OC中是成立的
//NSASCIIStringEncoding + NSNEXTSTEPStringEncoding == NSJapaneseEUCStringEncoding


enum Encoding {
    case ascii
    case nextstep
    case japaneseEUC
    case utf8
}


//于OC相比, swift编译器不支持这种操作
//let myEncoding = Encoding.ascii + Encoding.utf8


extension Encoding {
    var nsStringEncoding: String.Encoding {
        switch self {
        case .ascii: return String.Encoding.ascii
        case .nextstep: return String.Encoding.nextstep
        case .japaneseEUC: return String.Encoding.japaneseEUC
        case .utf8: return String.Encoding.utf8
        }
    }
}

extension Encoding {
    init?(enc: String.Encoding) {
        switch enc {
        case String.Encoding.ascii: self = .ascii
        case String.Encoding.nextstep: self = .nextstep
        case String.Encoding.japaneseEUC: self = .japaneseEUC
        case String.Encoding.utf8: self = .utf8
        default: return nil
        }
    }
}

//得到编码的本地化名称
func localizedEncodingName(encoding: Encoding) -> String {
    return .localizedName(of: encoding.nsStringEncoding)
}


//对第四章中根据首都名称获取人口数的方法(populationOfCapital)使用错误类型的enum加以改进
enum LookupError: Error {
    case CapitalNotFound
    case PopulationNotFound
}

enum PopulationResult {
    case Success(Int)
    case Error(LookupError)
}

//改进后可以这样来声明Success
let exampleSuccess: PopulationResult = .Success(1000)

let capitals = [
    "France": "Paris",
    "Spain": "Madrid",
    "The Netherlands": "Amsterdam",
    "Belgium": "Brussels"
]

let cities = ["Paris": 2241, "Madrid": 3165, "Amsterdam": 827, "Berlin": 3562]


//重写populationOfCapital方法
func populationOfCapital(country: String) -> PopulationResult {
    guard let capital = capitals[country] else {
        return .Error(.CapitalNotFound)
    }
    
    guard let population = cities[capital] else {
        return .Error(.PopulationNotFound)
    }
    
    return .Success(population)
}

//使用
switch populationOfCapital(country: "china") {
case let .Success(population):
    print("China's capital has \(population) thousand inhabitants")
case let .Error(error):
    print("Error: \(error)")
}






/*
 添加泛型
 */

//查询一个国家首都的市长的函数

let mayors = [
    "Paris": "Hidalgo",
    "Madrid": "Carmena",
    "Amsterdam": "van der Laan",
    "Berlin": "Muller"
]

func mayorOfCapital(country: String) -> String? {
    return capitals[country].flatMap { mayors[$0] }
}
//以上函数依然没有错误提示

//可以选择再创建一个MayorResult, 不过为此另外再创建一个错误类型不是一个好的设计, 所以可以重写一个PopulationResult和MayorResult都通用的Result类型,
enum Result<T, ErrorType> {
    case Success(T)
    case Error(ErrorType)
}

//之前的函数名为此将改为

// func populationOfCapital(country: String) -> Result<Int>
// func mayorOfCapital(country: String) -> Result<String>





/*
 Swift中的错误处理
 */
func populationOfCapital1(country: String) throws -> Int {
    guard let capital = capitals[country] else {
        throw LookupError.CapitalNotFound
    }
    
    guard let population = cities[capital] else {
        throw LookupError.PopulationNotFound
    }
    
    return population
}

do {
    let population = try populationOfCapital1(country: "France")
    print("France's population is \(population)")
} catch {
    print("Lookup error: \(error)")
}



/*
 可选值
 */

//Optional的定义与Result很像
enum Optional<T> {
    case none
    case some(T)
}

//为Result自定义类似Optional中?的语法糖

precedencegroup ComparativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}
infix operator ?? : ComparativePrecedence

func ??<T, ErrorType>(result: Result<T, ErrorType>, handlerError: (ErrorType) -> T) -> T {
    switch result {
    case let .Success(value):
        return value 
    case let .Error(error):
        return handlerError(error)
    }
}



let result: Result<Int, LookupError> = Result.Error(LookupError.CapitalNotFound)

result ?? { (error: LookupError) in
    
        switch error {
        case .CapitalNotFound:
            print("Capital Not Found")
            return 0
        case .PopulationNotFound:
            print("population Not Found")
            return 0
        }
}


// 实际开发中, result类型的错误管理并不一定会比optional更好用, 因为系统类型更容易被其他开发者接受, 并且內建的语法糖在使用上也更方便
// 但无疑使用result类型会使错误的返回更加清晰, 所以当需要在result和optional间选择时, 应根据情况权衡利弊

