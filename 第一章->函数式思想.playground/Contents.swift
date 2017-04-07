
/*
  第一章 : 函数式思想
*/

import UIKit


typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

//面向对象实现
extension Position {
    
    func inRange(range: Distance) -> Bool {
        return sqrt(x * x + y * y) <= range
    }
    
    func minus(p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    var length: Double {
        return sqrt(x * x + y * y)
    }
}

extension Ship {
    
    func canEngageShip(target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(p: self.position).length
        let friendlyDistance = target.position.minus(p: friendly.position).length
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && friendlyDistance > unsafeRange
    }
}


//函数式实现
//typealias Region = (Position) -> Bool
//
////圆心是原点时
//func circle(radius: Distance) -> Region {
//    return { point in point.length <= radius }
//}
//
////圆心非圆点
//func circle2(radius: Distance, center: Position) -> Region {
//    return { point in point.minus(p: center).length <= radius }
//}
//
//
//// 区域变换函数
////偏移
//func shift(region: @escaping Region, offset: Position) -> Region {
//    return { point in region(point.minus(p: offset)) }
//}
//
////反转
//func invert(region: @escaping Region) -> Region {
//    return { point in !region(point) }
//}
//
////相交
//func intersection(region1: @escaping Region, region2: @escaping Region) -> Region {
//    return { point in region1(point) && region2(point) }
//}
//
////合并
//func union(region1: @escaping Region, region2: @escaping Region) -> Region {
//    return { point in region1(point) || region2(point) }
//}
//
////相离
//func difference(region: @escaping Region, minus: @escaping Region) -> Region {
//    return intersection(region1: region, region2: invert(region: minus))
//}
//
//
//extension Ship {
//    
//    func canEngageShip2(target: Ship, friendly: Ship) -> Bool {
//        //获得射程范围的Region
//        let rangeRegion = difference(region: circle(radius: firingRange), minus: circle(radius: unsafeRange))
//        let firingRegion = shift(region: rangeRegion, offset: position)
//        
//        //获得friendly unsafe区域的Region
//        let friendlyRegion = shift(region: circle(radius: unsafeRange), offset: friendly.position)
//        //得到符合条件的Region
//        let resultRegion = difference(region: firingRegion, minus: friendlyRegion)
//        
//        return resultRegion(target.position)
//    }
//}


//函数实现2
struct Region {
    
    let lookup: (Position) -> Bool
    
    init(lookup: @escaping (Position) -> Bool) {
        self.lookup = lookup
    }
    
}

extension Region {
    
    
    static func circle(radius: Double) -> Region {
        return Region(lookup: { point in sqrt(point.x * point.x + point.y * point.y) <= radius})
    }
    
    func shift(offset: Position) -> Region {
        let lookup = self.lookup
        return Region(lookup: { point in lookup(offset)});
    }
    
    func invert() -> Region {
        let lookup = self.lookup
        return Region(lookup: {point in !lookup(point)})
    }
    
    func intersection(region: Region) -> Region {
        let lookup = self.lookup
        return Region(lookup: {point in lookup(point) && region.lookup(point) })
    }
    
    func union(region: Region) -> Region {
        let lookup = self.lookup
        return Region(lookup: { point in lookup(point) || region.lookup(point) })
    }
    
    func difference(region: Region) -> Region {
        let lookup = self.lookup
        return Region(lookup: { point in lookup(point) && region.invert().lookup(point) })
    }
    
}

extension Ship {
    
    func canEngageShip2(target: Ship, friendly: Ship) -> Bool{
        let safeRegion = Region.circle(radius: firingRange)
        let unsafeRegion = Region.circle(radius: unsafeRange)
        
        let firingRegion = safeRegion.difference(region: unsafeRegion).shift(offset: self.position)
        
        let friendlyRegion = Region.circle(radius: unsafeRange).shift(offset: friendly.position)
        
        let resultRegion = firingRegion.difference(region: friendlyRegion)
        
        return resultRegion.lookup(target.position)
    }
}










