//
//  TextBorderStyle.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum TextBorderStyle: String, EnumPropertyType {
    public static let enumName = "UITextBorderStyle"

    case none
    case line
    case bezel
    case roundedRect

    static var allValues: [TextBorderStyle] = [.none, .line, .bezel, .roundedRect]

    public static var xsdType: XSDType {
        let values = Set(TextBorderStyle.allValues.map { $0.rawValue })

        return .enumeration(EnumerationXSDType(name: TextBorderStyle.enumName, base: .string, values: values))
    }
}

#if ReactantRuntime
    import UIKit

    extension TextBorderStyle {

        public var runtimeValue: Any? {
            switch self {
            case .none:
                return UITextBorderStyle.none.rawValue
            case .line:
                return UITextBorderStyle.line.rawValue
            case .bezel:
                return UITextBorderStyle.bezel.rawValue
            case .roundedRect:
                return UITextBorderStyle.roundedRect.rawValue
            }
        }
    }
    
#endif
