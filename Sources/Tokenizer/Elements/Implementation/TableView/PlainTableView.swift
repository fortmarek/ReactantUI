//
//  PlainTableView.swift
//  Reactant
//
//  Created by Tadeas Kriz on 4/22/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
import Reactant
import RxDataSources
#endif

public class PlainTableView: View, ComponentDefinitionContainer {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.plainTableView.allProperties
    }

    public override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.plainTableView.allProperties
    }

    public var cellType: String
    public var cellDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return cellDefinition?.componentTypes ?? [cellType]
    }

    public var isAnonymous: Bool {
        return cellDefinition?.isAnonymous ?? false
    }

    public var componentDefinitions: [ComponentDefinition] {
        return cellDefinition?.componentDefinitions ?? []
    }
    
    public override class var parentModuleImport: String {
        return "Reactant"
    }

    public class override func runtimeType() -> String {
        return "UITableView"
    }

    public override func initialization() -> String {
        return "PlainTableView<\(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize() -> XMLSerializableElement {
        var element = super.serialize()
        element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
        return element
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let exampleCount = ToolingProperties.plainTableView.exampleCount.get(from: self.toolingProperties) ?? 5
        let tableView =  Reactant.PlainTableView<CellWrapper>(cellFactory: {
            CellWrapper(wrapped: createCell())
        }).with(state: .items(Array(repeating: (), count: exampleCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension

        return tableView
    }

    public final class CellHack: ViewBase<Void, Void> {
        private let wrapped: UIView

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init()
        }

        public override func loadView() {
            children(
                wrapped
            )
        }

        public override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    #endif
}

public class PlainTableViewProperites: PropertyContainer {
    public let tableViewProperties: TableViewProperties
    public let emptyLabelProperties: LabelProperties
    public let loadingIndicatorProperties: ActivityIndicatorProperties

    public required init(configuration: Configuration) {
        tableViewProperties = configuration.namespaced(in: "tableView", TableViewProperties.self)
        emptyLabelProperties = configuration.namespaced(in: "emptyLabel", LabelProperties.self)
        loadingIndicatorProperties = configuration.namespaced(in: "loadingIndicator", ActivityIndicatorProperties.self)

        super.init(configuration: configuration)
    }
}

public class PlainTableViewToolingProperties: PropertyContainer {
    public let exampleCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        exampleCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}
