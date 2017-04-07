//: Playground - noun: a place where people can play

import UIKit


//使用二叉搜索树来定义一个无序集合

indirect enum BinarySearchTree<Element: Comparable> {
    case leaf
    case node(BinarySearchTree<Element>, Element, BinarySearchTree<Element>)
}

//空的树
let leaf: BinarySearchTree<Int> = BinarySearchTree.leaf
//在节点上存了值5
let five: BinarySearchTree<Int> = BinarySearchTree.node(leaf, 5, leaf)


//编写两个方法创建空树或者有初始值的树
extension BinarySearchTree {
    
    init() {
        self = .leaf
    }
    
    init(_ value: Element) {
        self = .node(.leaf, value, .leaf)
    }
    
}

//计算一棵树中存值的个数
extension BinarySearchTree {
    var count: Int {
        switch self {
        case .leaf:
            return 0
        case let .node(left, _, right):
            return 1 + left.count + right.count
        }
    }
}


//计算树中所有元素组成的数组
extension BinarySearchTree {
    var elements: [Element] {
        switch self {
        case .leaf:
            return []
        case let .node(left, x, right):
            return left.elements + [x] + right.elements
        }
    }
}

//开始使用二叉树制作一个 无序集合

//检查是否为空
extension BinarySearchTree {
    var isEmpty: Bool {
        if case .leaf = self  {
            return true
        }
        
        return false
    }
}



/*
 只有符合下面几点的非空树才会是 二叉搜索树
 
 1.所有储存在左子树的值都小于其根节点的值
 2.所有储存在右子树的值都大于其根节点的值
 3.其左右子树都是二叉搜索树
 */


// 添加一个(低效率的)属性来检查BinarySearchTree实际上是不是一颗二叉搜索书
extension BinarySearchTree where Element: Comparable {
    var isBST: Bool {
        switch self {
        case .leaf:
            return true
        case let .node(left, x, right):
            return left.elements.all { y in y < x }
                && right.elements.all { y in y > x}
                && left.isBST
                && right.isBST
        }
    }
}


// all方式用于检查数组中的元素是否都符合条件
extension Sequence {
    func all(_ predicate: (Self.Iterator.Element) -> Bool) -> Bool{
        for x in self where !predicate(x) {
            return false
        }
        
        return true
    }
}


// 查找一个元素是否在树中
extension BinarySearchTree {
    func contains(_ x: Element) -> Bool {
        switch self {
        case .leaf:
            return false
        case let .node(_, y, _) where x == y:
            return true
        case let .node(left, y, _) where x < y:
            return left.contains(x)
        case let .node(_, y, right) where x > y:
            return right.contains(x)
        default:
            fatalError("The impossible occurred")
        }
    }
}

// 插入方法
extension BinarySearchTree {
    mutating func insert(_ x: Element) {
        switch self {
        case .leaf:
            self = BinarySearchTree(x)
        case .node(var left, let y, var right):
            if x < y { left.insert(x) }
            if x > y { right.insert(x) }
            self = .node(left, y, right)
        }
    }
}


//值并没有被修改, 被修改的是整个tree变量
let myTree: BinarySearchTree<Int> = BinarySearchTree()
var copied = myTree
copied.insert(5)
(myTree.elements, copied.elements)




// 8.2 基于字典树的自动补全
struct Trie<Element: Hashable> {
    let isElement: Bool
    //    let children: [Element: Trie<Element>]
    var children: [Element: Trie<Element>]
}

extension Trie {
    init() {
        isElement = false
        children = [:]
    }
}

//将字典树展平(flatten)为一个包含全部元素的数组

extension Trie {
    var elements: [[Element]] {
        var result: [[Element]] = isElement ? [[]] : []
        for (key, value) in children {
            result += value.elements.map { [key] + $0 }
        }
        return result
    }
}


extension Array {
    var decompose: (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}

func sum(_ xs: [Int]) -> Int {
    guard let (head, tail) = xs.decompose else { return 0 }
    return head + sum(tail)
}


//func qsort(input: [Int]) -> [Int] {
//    guard let (pivot, rest) = input.decompose else { return [] }
//    let lesser = rest.filter { $0 < pivot }
//    let greater = rest.filter { $0 >= pivot }
//    return qsort(lesser) + [pivot] + qsort(greater)
//}

extension Trie {
    func lookup(_ key: [Element]) -> Bool {
        guard let (head, tail) = key.decompose else { return isElement }
        guard let subtrie = children[head] else { return false }
        return subtrie.lookup(tail)
    }
}

extension Trie {
    func withPrefix(_ prefix: [Element]) -> Trie<Element>? {
        prefix
        guard let (head, tail) = prefix.decompose else { return self }
        children
        guard let remainder = children[head] else { return nil }
        return remainder.withPrefix(tail)
    }
}

extension Trie {
    func autocomplete(key: [Element]) -> [[Element]] {
        return withPrefix(key)?.elements ?? []
    }
}

extension Trie {
    init(_ key: [Element]) {
        if let (head, tail) = key.decompose {
            let children = [head: Trie(tail)]
            self = Trie(isElement: false, children: children)
        } else {
            self = Trie(isElement: true, children: [:])
        }
    }
}

//extension Trie {
//    func insert(_ key: [Element]) -> Trie<Element> {
//        guard let (head, tail) = key.decompose else {
//            return Trie(isElement: true, children: children)
//        }
//        var newChildren = children
//        if let nextTrie = children[head] {
//            newChildren[head] = nextTrie.insert(tail)
//        } else {
//            newChildren[head] = Trie(tail)
//        }
//        return Trie(isElement: isElement, children: newChildren)
//    }
//}























//按照理解写出
extension Trie {
    func insert(_ key: [Element]) -> Trie<Element> {
        
        
        guard let (head, tial) = key.decompose else {
            return Trie(isElement: true, children: [:])
        }
        
        var newChild = children
        if let childTrie = children[head] {
            newChild[head] = childTrie.insert(tial)
        } else {
            newChild[head] = Trie(tial)
        }
        
        return Trie(isElement: isElement, children: newChild)
    }
}






var trie: Trie<String> = Trie(["c", "a", "t"])

trie.elements

trie = trie.insert(["c", "a", "r"])

trie.elements

trie.insert(["c", "a", "r", "t"]).elements



// 练习: 将insert写成mutating函数
extension Trie {
    mutating func mutatingInsert( _ keys: [Element]) -> Trie<Element> {
        
        guard let (head, tail) = keys.decompose else {
            return Trie(isElement: true, children: [:])
        }
        
        if let tempTrie = children[head] {
            children[head] = tempTrie.insert(tail)
        } else {
            children[head] = Trie(tail)
        }
        
        return self
    }
}



var trie2: Trie<String> = Trie(["c", "a", "t"])

trie2.elements

trie2 = trie.mutatingInsert(["c", "a", "r"])

trie2.elements

trie2.mutatingInsert(["c", "a", "r", "t"]).elements



trie2.withPrefix(["c", "a"])?.elements

// 封装, 从一个单词列表来构建字典树

func buildStringTrie(words: [String]) -> Trie<Character> {
    let emptyTrie = Trie<Character>()
    return words.reduce(emptyTrie) { trie, word in
        return trie.insert(Array(word.characters))
    }
}


func autocompleteString(_ knownWords: Trie<Character>, word: String) -> [String] {
    
    let chars = Array(word.characters)
    let result = knownWords.autocomplete(key: chars)
    return result.map { chars in
        word + String(chars)
    }
}


let contents = ["cat", "car", "cart", "dog"]
let trieOfWords = buildStringTrie(words: contents)
autocompleteString(trieOfWords, word: "ca")





