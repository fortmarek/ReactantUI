//
//  EnumPropertyType.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

public protocol EnumPropertyType: RawRepresentable, SupportedPropertyType {
    static var enumName: String { get }
}

extension EnumPropertyType where Self.RawValue == String {
    public var generated: String {
        return "\(Self.enumName).\(rawValue)"
    }
}

extension SupportedPropertyType where Self: RawRepresentable, Self.RawValue == String {
    #if SanAndreas
    public func dematerialize() -> String {
        return rawValue
    }
    #endif

    public static func materialize(from value: String) throws -> Self {
        guard let materialized = Self(rawValue: value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }
}
