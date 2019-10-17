//
//  NSObject+RetainedObjects.swift
//  RetainCycleCheck
//
//  Created by 翟泉 on 2019/10/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation

public extension NSObject {
    /// 返回发生循环引用的引用栈数组
    func retainCycles() -> [RetainStack] {
        var list = [RetainStack]()
        retainCycles(stack: RetainStack(objects: [self]), stackList: &list)
        return list
    }

    /// 遍历当前对象直接和间接强引用的对象
    /// - Parameter stack: 当前遍历的引用栈
    /// - Parameter stackList: 保存发生循环引用的引用栈数组
    private func retainCycles(stack: RetainStack, stackList: inout [RetainStack]) {
        for object in retainedObjects() {
            if stack[0] == object {
                stackList.append(stack)
            } else if stack.contains(object) {
                continue
            } else {
                object.retainCycles(stack: stack + object, stackList: &stackList)
            }
        }
    }

    /// 返回当前对象强引用的对象
    func retainedObjects() -> [NSObject] {
        var result = [NSObject]()

        // Instance ivar
        NSObject.strongReferencedIvars(for: classForCoder).compactMap {
            ivar_getName($0)
        }.map {
            String(cString: $0)
        }.compactMap {
            value(forKey: $0) as? NSObject
        }.forEach {
            result.append($0)
        }

        // TODO: Associated object
        // TODO: Block
        // TODO: Struct
        // TODO: Cache

        return result
    }
}

extension NSObject {
    /// 返回类强引用的实例变量
    static func strongReferencedIvars(for cls: AnyClass) -> [Ivar] {
        var ivars = [Ivar]()

        #warning("使用Swift实现的类继承与NSObject调用class_getIvarLayout也会返回NULL，也就是无法通过这个方式确定Swift实现的类的实例变量是不是强引用")
        guard let ivarLayout = class_getIvarLayout(cls) else { return [] }

        var ivarCount: UInt32 = 0
        let ivarList = class_copyIvarList(cls, &ivarCount)

        var minimumIvarIndex = 1
        if ivarCount > 0 {
            minimumIvarIndex = ivar_getOffset(ivarList![0]) / MemoryLayout<Int>.size
        }

        let parsedLayout = layoutAsIndexes(forDescription: ivarLayout, minimumIvarIndex: minimumIvarIndex)

        for index in 0..<ivarCount {
            guard let ivar = ivarList?[Int(index)] else { break }
            let ivarLayoutIndex = ivar_getOffset(ivar) / MemoryLayout<Int>.size
            if parsedLayout.contains(ivarLayoutIndex) {
                ivars.append(ivar)
            }
        }
        free(ivarList)

        if let superClass = class_getSuperclass(cls), superClass != cls {
            ivars.append(contentsOf: strongReferencedIvars(for: superClass))
        }
        return ivars
    }

    static func layoutAsIndexes(forDescription ivarLayout: UnsafePointer<UInt8>, minimumIvarIndex: Int) -> NSIndexSet {
        let indexs = NSMutableIndexSet()
        var currentIndex = minimumIvarIndex

        var offset = 0
        while ivarLayout[offset] != 0x00 {
            let upperNibble = Int((ivarLayout[offset] & 0xf0) >> 4)
            let lowerNibble = Int(ivarLayout[offset] & 0xf)

            currentIndex += upperNibble
            indexs.add(in: NSMakeRange(currentIndex, lowerNibble))
            currentIndex += lowerNibble

            offset += 1
        }

        return indexs
    }
}

public extension NSObject {
    struct RetainStack: CustomStringConvertible {
        private var retainList = [NSObject]()
        private var retainSet = Set<NSObject>()

        init(objects: [NSObject]) {
            retainList = objects
            retainSet.formIntersection(objects)
        }

        mutating func append(_ element: NSObject) {
            retainSet.insert(element)
            retainList.append(element)
        }

        func contains(_ element: NSObject) -> Bool {
            return retainSet.contains(element)
        }

        subscript(index: Int) -> NSObject {
            return retainList[index]
        }

        public static func +(lhs: RetainStack, rhs: NSObject) -> RetainStack {
            var stack = lhs
            stack.append(rhs)
            return stack
        }

        /**
         |-> 0x7ff72ad15b00-1
         |     |- 0x7ff72ad15b90-2
         |        |- 0x7ff72ad15bd0-3
         ^-----------|
         */
        public var description: String {
            var text = "\n|-> "
            var offset = text.count
            text += "\(retainList[0].description)\n"
            for index in 1..<retainList.count {
                text += "|"
                text += String(repeating: " ", count: offset)
                text += "|- \(retainList[index].description)\n"
                offset += 3
            }
            text += "^\(String(repeating: "-", count: offset))|\n"
            return text
        }
    }
}
