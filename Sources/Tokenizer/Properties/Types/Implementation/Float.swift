//
//  Float+SupportedPropertyType.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Float: SupportedPropertyType {

    public var generated: String {
        return "\(self)"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
    return self
    }
    #endif

    #if SanAndreas
    public func dematerialize() -> String {
    return generated
    }
    #endif

    public static func materialize(from value: String) throws -> Float {
        guard let materialized = Float(value) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return materialized
    }

    public static var xsdType: XSDType {
        return .builtin(.decimal)
    }
}
