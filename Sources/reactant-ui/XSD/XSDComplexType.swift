//
//  XSDComplexType.swift
//  ReactantUIPackageDescription
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDComplexChoiceType {
    let name: String
    var elements: Set<XSDElement>
}

extension XSDComplexChoiceType: Hashable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDComplexChoiceType, rhs: XSDComplexChoiceType) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDComplexChoiceType: XMLElementSerializable {
    func serialize() -> XMLSerializableElement {
        let elements = self.elements.map { $0.serialize() }

        let choice = XMLSerializableElement(name: "xs:choice",
                                            attributes: [XMLSerializableAttribute(name: "maxOccurs", value: "unbounded"),
                                                         XMLSerializableAttribute(name: "minOccurs", value: "0")],
                                            children: elements)

        return XMLSerializableElement(name: "xs:complexType",
                                      attributes: [XMLSerializableAttribute(name: "name", value: name)],
                                      children: [choice])
    }
}
