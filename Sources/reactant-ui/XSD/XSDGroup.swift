//
//  XSDGroup.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

struct XSDGroup {
    let name: String
    var elements: Set<XSDElement>
}

extension XSDGroup: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDGroup, rhs: XSDGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDGroup: XMLElementSerializable {
    func serialize() -> XMLSerializableElement {
        return XMLSerializableElement(name: "xs:group",
                            attributes: [
                                XMLSerializableAttribute(name: "name", value: name)
                            ],
                            children: [XMLSerializableElement(name: "xs:choice", attributes: [], children: elements.map { $0.serialize() })])
    }
}
