//
//  CGColorPropertyType.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public struct CGColorPropertyType: SupportedPropertyType {
    public let color: UIColorPropertyType

    public var generated: String {
        return "\(color.generated).cgColor"
    }

    #if SanAndreas
    public func dematerialize() -> String {
        return color.dematerialize()
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return (color.runtimeValue as? UIColor)?.cgColor
    }
    #endif

    public init(color: UIColorPropertyType) {
        self.color = color
    }

    public static func materialize(from value: String) throws -> CGColorPropertyType {
        let materializedValue = try UIColorPropertyType.materialize(from: value)
        return CGColorPropertyType(color: materializedValue)
    }

    public static var xsdType: XSDType {
        return Color.xsdType
    }
}
