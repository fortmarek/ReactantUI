//
//  TextAlignment.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum TextAlignment: String, EnumPropertyType {
    public static let enumName = "NSTextAlignment"

    case left
    case right
    case center
    case justified
    case natural

    static var allValues: [TextAlignment] = [.left, .right, .center, .justified, .natural]

    public static var xsdType: XSDType {
        let values = Set(TextAlignment.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: TextAlignment.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension TextAlignment {

        public var runtimeValue: Any? {
            switch self {
            case .center:
                return NSTextAlignment.center.rawValue
            case .left:
                return NSTextAlignment.left.rawValue
            case .right:
                return NSTextAlignment.right.rawValue
            case .justified:
                return NSTextAlignment.justified.rawValue
            case .natural:
                return NSTextAlignment.natural.rawValue
            }
        }
    }
#endif
