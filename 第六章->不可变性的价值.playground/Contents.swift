//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var x: Int = 1
let y: Int = 2

x = 3 //没问题
//y = 4 //被编译器拒绝


struct PointStruct {
    var x: Int
    var y: Int
}

var structPoint = PointStruct(x: 1, y: 2)
var sameStructPoint = structPoint
sameStructPoint.x = 3

//并不会修改原来的structPoint的值, 因为struct是值类型
structPoint.x




class PointClass {
    var x: Int
    var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

var classPoint = PointClass(x: 1, y: 2)
var sameClassPoint = classPoint
sameClassPoint.x = 3

//因为Class是引用类型
classPoint.x







func setStructToOrigin(point: PointStruct) -> PointStruct {
    
    var point = point
    point.x = 0
    point.y = 0
    return point
}

var structOrigin: PointStruct = setStructToOrigin(point: structPoint)
//因为struct是值类型, 在该方法中只是修改了另外的一个复制版本, 并不会对原本的有影响
structPoint.x


func setClassToOrigin(point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}

var classOrigin = setClassToOrigin(point: classPoint)
//类 则是引用类型, 所以该方法正常工作
classPoint.x






let immutablePoint = PointStruct(x: 0, y: 0)

// 编译器不接受
//immutablePoint = PointStruct(x: 1, y: 2)

// 改变任意属性也会被拒绝
//immutablePoint.x = 3


var mutablePoint = PointStruct(x: 1, y: 1)

mutablePoint.x = 3


//使用let关键字声明了x和y属性后, 就再也不能修改他们, 无论结构体的实例是可选的还是不可选的
struct ImmutablePointStruct {
    let x: Int
    let y: Int
}

var immutablePoint2 = ImmutablePointStruct(x: 1, y: 1)

//同样被拒绝, 因为该属性是用let声明的
//immutablePoint2.x = 3














