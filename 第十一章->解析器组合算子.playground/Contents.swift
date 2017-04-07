//: Playground - noun: a place where people can play

import UIKit
import Foundation


struct Parser<Token, Result> {
    let p: (ArraySlice<Token>) -> AnySequence<(Result, ArraySlice<Token>)>
}

struct OneIterator<Element>: IteratorProtocol {
    
    var count = 0
    let oneElement: Element?
    
    public init(_ oneElement: Element?) {
        self.oneElement = oneElement
    }
    
    mutating func next() -> Element? {
        guard count==0 else {
            return nil
        }
        
        count += 1
        return oneElement
    }
}

func one<A>(_ x: A) -> AnySequence<A> {
    return AnySequence{ OneIterator(x) }
}

func none<T>() -> AnySequence<T> {
    return AnySequence{ OneIterator(nil) }
}
extension ArraySlice {
    var head: Element? {
        return isEmpty ? nil : self[0]
    }
    
    var tail: ArraySlice<Element> {
        guard !isEmpty else { return self }
        return self[(self.startIndex+1)..<self.endIndex]
    }
    
    var decompose: (head: Element, tail: ArraySlice<Element>)? {
        return isEmpty ? nil
            : (self[self.startIndex], self.tail)
    }
}

func parseA() -> Parser<Character, Character> {
    let a: Character = "a"
    return Parser { x in
        guard let (head, tail) = x.decompose , head == a else {
            return none()
        }
        
        return one((a, tail))
    }
}


func testParser<A>(_ parser: Parser<Character, A>, _ input: String) -> String {
    var result: [String] = []
    for (x, s) in parser.p(ArraySlice(input.characters)) {
        result += ["Success, found \(x), remainder: \(Array(s))"]
    }
    return result.isEmpty ? "Parsing failed." : result.joined(separator: "\n")
}

testParser(parseA(), "abcd")

testParser(parseA(), "test")

func parseCharacter(_ character: Character) -> Parser<Character, Character> {
    return Parser { x in
        guard let (head, tail) = x.decompose ,head == character else {
            return none()
        }
        
        return one((character, tail))
    }
}

testParser(parseCharacter("t"), "test")


func satisfy<Token>(_ condition: @escaping (Token) -> Bool) -> Parser<Token, Token> {
    return Parser { x in
        guard let (head, tail) = x.decompose ,condition(head) else {
            return none()
        }
        return one((head, tail))
    }
}

func token<Token: Equatable>(_ t: Token) -> Parser<Token, Token> {
    return satisfy { $0 == t }
}


testParser(token("t"), "test")

precedencegroup RightPrecedence {
    associativity: right
    higherThan: AdditionPrecedence
}

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}
precedencegroup SeqOmitPrecedence {
    associativity: left
    lowerThan: AdditionPrecedence
}

infix operator <|> : RightPrecedence

func <|> <Token, A>(l: Parser<Token, A>, r: Parser<Token, A>) -> Parser<Token, A> {
    return Parser { l.p($0) + r.p($0) }
}

func +<G: Sequence, H: Sequence>(first: G, second: H) -> AnySequence<G.Iterator.Element>
    where G.Iterator.Element == H.Iterator.Element {
        var gIterator = first.makeIterator()
        var hIterator = second.makeIterator()
        return AnySequence{ AnyIterator { gIterator.next() ?? hIterator.next() } }
}

func +<G: IteratorProtocol, H: IteratorProtocol>
    (first: G, second: H) -> AnyIterator<G.Element> where G.Element == H.Element
{
    var tempG = first
    var tempH = second
    return AnyIterator { tempG.next() ?? tempH.next() }
}

func look(_ xs: AnySequence<Any>) {
    for x in xs {
        print(x)
    }
}

func sequence<Token, A, B>(_ l: Parser<Token, A>, _ r: Parser<Token, B>) -> Parser<Token, (A, B)> {
    return Parser<Token, (A, B)> { input in
        let leftResults = l.p(input)
        let leftSequence = leftResults.flatMap {
            (a, leftRest) -> [((A, B), ArraySlice<Token>)] in
            let rightResults = r.p(leftRest)
            let sequence: [((A, B), ArraySlice<Token>)] = rightResults.map { b, rightResults in
                ((a, b), rightResults)
            }
            return sequence
        }
        return AnySequence(leftSequence)
    }
}


let x: Character = "x"
let y: Character = "y"

let p = sequence(token(x), token(y))
testParser(p, "xyz")

//let leftResult = token(x).p(ArraySlice("xyz".characters))
//let sequence1 = leftResult.makeIterator().next()
//sequence1?.0
//sequence1?.1
//
//sequence1.flatMap {_,_ in
//    return 1
//}
//sequence1
//
//leftResult.flatMap {_,_ in
//    return ("1", ["3","1"])
//}
//
//let sequence2 = leftResult.makeIterator()
//sequence2.next()



let z: Character = "z"
let p2 = sequence(sequence(token(x), token(y)), token(z))
testParser(p2, "xyz")

func sequence3<Token, A, B, C>(p1: Parser<Token, A>, p2: Parser<Token, B>, p3: Parser<Token, C>) -> Parser<Token, (A, B, C)> {
    typealias Result = ((A, B, C), ArraySlice<Token>)
    typealias Results = [Result]
    
    return Parser { input in
        let p1Result = p1.p(input)
        return AnySequence(p1Result.flatMap { (a, p1Rest) -> Results in
            let p2Result = p2.p(p1Rest)
            return p2Result.flatMap {
                (b, p2Rest) -> Results in
                let p3Result = p3.p(p2Rest)
                return p3Result.flatMap { (c, p3Rest) in
                    return ((a, b, c), p3Rest)
                }
            }
        })
    }
}

testParser(sequence3(p1: token(x), p2: token(y), p3: token(z)), "xyz")

func integerParser<Token>() -> Parser<Token, (Character) -> Int> {
    return Parser { input in
        return one(({ x in Int(String(x))! }, input))
    }
}



func combinator<Token, A, B>(_ l: Parser<Token, (A) -> B>, _ r: Parser<Token, A>) -> Parser<Token, B> {
    typealias Result = (B, ArraySlice<Token>)
    typealias Results = [Result]
    return Parser { input in
        let leftResults = l.p(input)
        return AnySequence(leftResults.flatMap { f, leftRemainder -> Results in
            let rightResults = r.p(leftRemainder)
            return rightResults.map {x, rightRemainder -> Result in
                (f(x), rightRemainder)
            }
        })
    }
}


let three: Character = "3"
testParser(combinator(integerParser(), token(three)), "3")


func pure<Token, A>(_ value: A) -> Parser<Token, A> {
    return Parser { one((value, $0)) }
}

func toInteger(_ c: Character) -> Int {
    return Int(String(c))!
}

testParser(combinator(pure(toInteger), token(three)), "3")


//柯里化
func toInteger2(_ c1: Character) -> (Character) -> Int {
    return { c2 in
        let combined = String(c1) + String(c2)
        return Int(combined)!
    }
}

testParser(combinator(combinator(pure(toInteger2), token(three)), token(three)), "33")

//增强combinator嵌套的可读性
infix operator <*> : SequencePrecedence

func <*><Token, A, B>(_ l: Parser<Token, (A) -> B>, _ r: Parser<Token, A>) -> Parser<Token, B> {
    typealias Result = (B, ArraySlice<Token>)
    typealias Results = [Result]
    return Parser { input in
        let leftResults = l.p(input)
        return AnySequence(leftResults.flatMap { (f, leftRemainder) -> Results in
            let rightResult = r.p(leftRemainder)
            return rightResult.map { (x, y) -> Result in
                (f(x), y)
            }
        })
    }
}

let parser2 = pure(toInteger2) <*> token(three) <*> token(three)
testParser(parser2, "33")

let a: Character = "a"
let b: Character = "b"

let aOrB = token(a) <|> token(b)
func combine(_ a: Character) -> (Character) -> (Character) -> String {
    return { b in { c in String([a, b, c]) } }
}


let parser3 = pure(combine) <*> aOrB <*> aOrB <*> token(b)
testParser(parser3, "abb")


func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}


func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D{
    return { x in { y in { z in f(x, y, z) } } }
}

let curryParser = pure(curry { String( [$0, $1, $2] ) }) <*> aOrB <*> aOrB <*> token(b)
testParser(curryParser, "abb")


//11.4 便利组合算子
extension CharacterSet {
    public func containsCharacter(_ c: Character) -> Bool {
        let scalars = String(c).unicodeScalars
        guard scalars.count == 1 else { return false }
        return contains(scalars.first!)
    }
}

let decimalDigit = satisfy { CharacterSet.decimalDigits.containsCharacter($0) }

typealias CharType = (Character) -> Bool
func characterFromSet(_ set: CharacterSet) -> Parser<Character, Character> {
    return satisfy(set.containsCharacter)
}


testParser(decimalDigit, "012")


func zeroOrMoreEndlessLoop<Token, A>(_ p: Parser<Token, A>) -> Parser<Token, [A]> {
    return (pure(prepend) <*> p <*> zeroOrMoreEndlessLoop(p)) <|> pure([])
}


func prepend<A>(_ l: A) -> ([A]) -> [A] {
    return { r in [l] + r }
}
//调用以上代码会进入死循环, 因为没有添加将zeroOrMore循环调用中断的行为
//通过lazy辅助函数, 将zeroOrMore的递归调用延缓到Parser运算时
func lazy<Token, A>(_ f: @escaping () -> Parser<Token, A>) -> Parser<Token, A> {
    return Parser { f().p($0) }
}

func zeroOrMore<Token, A>(_ p: Parser<Token, A>) -> Parser<Token, [A]> {
    return (pure(prepend) <*> p <*> lazy{zeroOrMore(p)} ) <|> pure([])
}

testParser(zeroOrMore(decimalDigit), "12345")

func oneOrMore<Token, A>(_ p: Parser<Token, A>) -> Parser<Token, [A]> {
    return pure(prepend) <*> p <*> zeroOrMore(p)
}

let number = pure { Int(String($0))! } <*> oneOrMore(decimalDigit)

testParser(number, "205")

infix operator </> : SequencePrecedence

func </> <Token, A, B>(_ l: @escaping (A) -> B, _ r: Parser<Token, A>) -> Parser<Token, B> {
    return pure(l) <*> r
}

//通过之前组装的解析器来创建一个解析器, 用于计算两个整数的和

let plus: Character = "+"
func add(x: Int) -> (Character) -> (Int) -> Int {
    return { _ in { y in x + y } }
}

let parserAddition = add </> number <*> token(plus) <*> number

testParser(parserAddition, "41+1")



//丢掉右侧解析器的解析结果
infix operator <* : SequencePrecedence
func <* <Token, A, B>(_ p: Parser<Token, A>, _ q: Parser<Token, B>) -> Parser<Token, A> {
    return { x in { _ in x } } </> p <*> q
}

//丢掉左侧解析器的解析结果
infix operator *> : SeqOmitPrecedence
func *> <Token, A, B>(_ p: Parser<Token, A>, _ q: Parser<Token, B>) -> Parser<Token, B> {
    return { _ in { $0 }} </> p <*> q
}

//使用上两个自定义运算发实现乘法解析器
let multity: Character = "*"
func parseMultiplication(_ x: Int) -> (Int) -> Int {
    return { y in  x * y }
}


let parserMutity = curry(*) </> number <* token(multity) <*> number
testParser(parserMutity, "8*8")



//制作简单的计算器
typealias Calculator = Parser<Character, Int>

func operator0(_ character: Character,
               _ evaluate: @escaping (Int, Int) -> Int,
               _ operand: Calculator) -> Calculator {
    return curry { evaluate($0, $1) } </> operand <* token(character) <*> operand
}

func pAtom0() -> Calculator { return number }
func pMultiply0() -> Calculator { return operator0("*", *, pAtom0()) }
func pAdd0() -> Calculator { return operator0("+", +, pMultiply0()) }
func pExpression0() -> Calculator { return pAdd0() }

//之所以会解析失败, 是因为加法表达式被定义为 (乘法表达式) + (乘法表达式) , 但是运算式中却是 数字1 + (乘法表达式) , 必须使解析方法既能解析 表达式 也能解析 单个运算对象
testParser(pExpression0(), "1+3*3")

func operator1(_ character: Character,
               _ evaluate: @escaping (Int, Int) -> Int,
               _ operand: Calculator) -> Calculator {
    let withOperator = curry { evaluate($0, $1) } </> operand <* token(character) <*> operand
    return withOperator <|> operand
}

func pAtom1() -> Calculator { return number }
func pMultiply1() -> Calculator { return operator1("*", *, pAtom1()) }
func pAdd1() -> Calculator { return operator1("+", +, pMultiply1()) }
func pExpression1() -> Calculator { return pAdd1() }

testParser(pExpression1(), "1+3*3")


//增加多一层抽象, 添加更多的运算符
typealias Op = (Character, (Int, Int) -> Int)
let operatorTable: [Op] = [("*", *), ("/", /), ("+", +), ("-", -)]

func pExpression2() -> Calculator {
    return operatorTable.reduce(number) { (next: Calculator, op: Op) in
        operator1(op.0, op.1, next)
    }
}


testParser(pExpression2(), "1+3*3")



//优化性能
infix operator </ : SequencePrecedence
func </ <Token, A, B>(_ l: A, _ r: Parser<Token, B>) -> Parser<Token, A> {
    return pure(l) <* r
}

func optionallyFollowed<A>(_ l: Parser<Character, A>, _ r: Parser<Character, (A)-> A>) -> Parser<Character, A> {
    let apply: (A)-> ((A) -> A) -> A = { x in { f in f(x) } }
    return apply </> l <*> ( r <|> pure { $0 } )
}

func op(_ character: Character,
        _ evaluate: @escaping (Int, Int) -> Int,
        _ operand: Calculator) -> Calculator {
    let withOperator = curry(flip(evaluate)) </ token(character) <*> operand
    return optionallyFollowed(operand, withOperator)
}

func flip<A, B, C>(_ f: @escaping (B, A) -> C) -> (A, B) -> C {
    return { (x, y) in f(y, x) }
}

func eof<A>() -> Parser<A, ()> {
    return Parser { stream in
        if (stream.isEmpty) {
            return one(((), stream))
        }
        return none()
    }
}

func pExpression() -> Calculator {
    return operatorTable.reduce(number) { next, inOp in
        op(inOp.0, inOp.1, next)
    }
}

testParser(pExpression() <* eof(), "10-3*2")



