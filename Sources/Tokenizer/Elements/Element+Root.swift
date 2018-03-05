//
//  Element+Root.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public protocol ComponentDefinitionContainer {
    var componentTypes: [String] { get }

    var componentDefinitions: [ComponentDefinition] { get }
}

public struct ComponentDefinition: XMLElementDeserializable, UIContainer, StyleContainer, ComponentDefinitionContainer {
    public var type: String
    public var isRootView: Bool
    public var styles: [Style]
    public var stylesName: String
    public var children: [UIElement]
    public var edgesForExtendedLayout: [RectEdge]
    public var isAnonymous: Bool

    public var properties: [Property]
    public var toolingProperties: [String: Property]

    public var requiredImports: Set<String> {
        return Set(arrayLiteral: "Reactant").union(children.flatMap { $0.requiredImports })
    }

    public var componentTypes: [String] {
        return [type] + ComponentDefinition.componentTypes(in: children)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return [self] + ComponentDefinition.componentDefinitions(in: children)
    }

    public var addSubviewMethod: String {
        return "addSubview"
    }

    #if ReactantRuntime
    public func add(subview: UIView, toInstanceOfSelf: UIView) {
        toInstanceOfSelf.addSubview(subview)
    }
    #endif

    public init(node: XMLElement, type: String) throws {
        self.type = type
        isRootView = node.value(ofAttribute: "rootView") ?? false
        styles = try node.singleOrNoElement(named: "styles")?.xmlChildren.flatMap { try $0.value() as Style } ?? []
        stylesName = try node.singleOrNoElement(named: "styles")?.attribute(by: "name")?.text ?? "Styles"
        children = try View.deserialize(nodes: node.xmlChildren)
        edgesForExtendedLayout = (node.attribute(by: "extend")?.text).map(RectEdge.parse) ?? []
        isAnonymous = node.value(ofAttribute: "anonymous") ?? false

        toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: ToolingProperties.componentDefinition.allProperties, in: node)
        properties = try PropertyHelper.deserializeSupportedProperties(properties: View.availableProperties, in: node)
    }

    public static func deserialize(_ node: SWXMLHash.XMLElement) throws -> ComponentDefinition {
        return try ComponentDefinition(node: node, type: node.value(ofAttribute: "type"))
    }

}

extension ComponentDefinition {
    static func componentTypes(in elements: [UIElement]) -> [String] {
        return elements.flatMap { element -> [String] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentTypes
            case let container as UIContainer:
                return componentTypes(in: container.children)
            default:
                return []
            }
        }
    }

    static func componentDefinitions(in elements: [UIElement]) -> [ComponentDefinition] {
        return elements.flatMap { element -> [ComponentDefinition] in
            switch element {
            case let container as ComponentDefinitionContainer:
                return container.componentDefinitions
            case let container as UIContainer:
                return componentDefinitions(in: container.children)
            default:
                return []
            }
        }
    }
}

extension ComponentDefinition: MagicElementSerializable {

    public func serialize() -> MagicElement {
        var builder = MagicAttributeBuilder()

        if isRootView {
            builder.attribute(name: "rootView", value: "true")
        }

        let extend = edgesForExtendedLayout.map { $0.rawValue }.joined(separator: " ")
        if !extend.isEmpty {
            builder.attribute(name: "extend", value: extend)
        }
        if isAnonymous {
            builder.attribute(name: "anonymous", value: "true")
        }

        let styleNameAttribute = stylesName == "Styles" ? [] : [MagicAttribute(name: "name", value: stylesName)]
        let stylesElement = styles.isEmpty ? [] : [MagicElement(name: "styles", attributes: styleNameAttribute, children: styles.map { $0.serialize() })]

        let childElements = children.map { $0.serialize() }

        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
            toolingProperties.map { _, property in property.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif

        var viewElement = MagicElement(name: "Component", attributes: builder.attributes, children: stylesElement + childElements)
        viewElement.attributes.insert(MagicAttribute(name: "type", value: type), at: 0)

        return viewElement
    }
}

public final class ComponentDefinitionToolingProperties: PropertyContainer {
    public let preferredSize: ValuePropertyDescription<PreferredSize>

    public required init(configuration: Configuration) {
        preferredSize = configuration.property(name: "tools:preferredSize")
        super.init(configuration: configuration)
    }
}

