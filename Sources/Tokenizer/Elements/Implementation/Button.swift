//
//  Button.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class Button: Container {

    public override class var availableProperties: [PropertyDescription] {
        return Properties.button.allProperties
    }
    
    public class override func runtimeType() -> String {
        return "UIButton"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIButton()
    }
    #endif
}

public class ButtonProperties: ControlProperties {
    public let title: ControlStatePropertyDescription<TransformedText>
    public let titleColor: ControlStatePropertyDescription<UIColorPropertyType>
    public let backgroundColorForState: ControlStatePropertyDescription<UIColorPropertyType>
    public let titleShadowColor: ControlStatePropertyDescription<UIColorPropertyType>
    public let image: ControlStatePropertyDescription<Image>
    public let backgroundImage: ControlStatePropertyDescription<Image>
    public let reversesTitleShadowWhenHighlighted: AssignablePropertyDescription<Bool>
    public let adjustsImageWhenHighlighted: AssignablePropertyDescription<Bool>
    public let adjustsImageWhenDisabled: AssignablePropertyDescription<Bool>
    public let showsTouchWhenHighlighted: AssignablePropertyDescription<Bool>
    public let contentEdgeInsets: AssignablePropertyDescription<EdgeInsets>
    public let titleEdgeInsets: AssignablePropertyDescription<EdgeInsets>
    public let imageEdgeInsets: AssignablePropertyDescription<EdgeInsets>
    
    public let titleLabel: LabelProperties
    public let imageView: ImageViewProperties
    
    public required init(configuration: PropertyContainer.Configuration) {
        title = configuration.property(name: "title")
        titleColor = configuration.property(name: "titleColor")
        backgroundColorForState = configuration.property(name: "backgroundColor")
        titleShadowColor = configuration.property(name: "titleShadowColor")
        image = configuration.property(name: "image")
        backgroundImage = configuration.property(name: "backgroundImage")
        reversesTitleShadowWhenHighlighted = configuration.property(name: "reversesTitleShadowWhenHighlighted")
        adjustsImageWhenHighlighted = configuration.property(name: "adjustsImageWhenHighlighted")
        adjustsImageWhenDisabled = configuration.property(name: "adjustsImageWhenDisabled")
        showsTouchWhenHighlighted = configuration.property(name: "showsTouchWhenHighlighted")
        contentEdgeInsets = configuration.property(name: "contentEdgeInsets")
        titleEdgeInsets = configuration.property(name: "titleEdgeInsets")
        imageEdgeInsets = configuration.property(name: "imageEdgeInsets")
        titleLabel = configuration.namespaced(in: "titleLabel", optional: true, LabelProperties.self)
        imageView = configuration.namespaced(in: "imageView", optional: true, ImageViewProperties.self)
        
        super.init(configuration: configuration)
    }
}

// FIXME maybe create Control Element and move it there
public class ControlProperties: ViewProperties {
    public let isEnabled: AssignablePropertyDescription<Bool>
    public let isSelected: AssignablePropertyDescription<Bool>
    public let isHighlighted: AssignablePropertyDescription<Bool>
    public let contentVerticalAlignment: AssignablePropertyDescription<ControlContentVerticalAlignment>
    public let contentHorizontalAlignment: AssignablePropertyDescription<ControlContentHorizontalAlignment>
    
    public required init(configuration: PropertyContainer.Configuration) {
        isEnabled = configuration.property(name: "isEnabled", key: "enabled")
        isSelected = configuration.property(name: "isSelected", key: "selected")
        isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
        contentVerticalAlignment = configuration.property(name: "contentVerticalAlignment")
        contentHorizontalAlignment = configuration.property(name: "contentHorizontalAlignment")
        
        super.init(configuration: configuration)
    }
}
