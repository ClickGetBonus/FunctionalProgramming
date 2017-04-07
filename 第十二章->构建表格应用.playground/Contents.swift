//: Playground - noun: a place where people can play

import UIKit

struct Parser<A> {
    typealias Stream = String.CharacterView
    let parser: (Stream) -> (A, Stream)
}

func parserA() -> Parser<Character> {
    let a: Character = "a"
    return Parser { x in
        guard let (head, tail) = Array(x).decompose(), head == a else {
            return 
        }
        
        
    }
}



extension Array {
    func decompose() -> (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex-1], Array(self.dropFirst()))
    }
}
