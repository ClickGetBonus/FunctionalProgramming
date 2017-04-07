//: Playground - noun: a place where people can play

import UIKit
import CoreGraphics

max(1, 2)


extension Sequence where Iterator.Element == CGFloat {
    func normalize() -> [CGFloat] {
        let maxVal = self.reduce(0){ $0 > $1 ? $0 : $1 }
        return self.map { $0 / maxVal }
    }
}
