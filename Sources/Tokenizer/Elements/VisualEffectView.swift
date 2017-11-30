//
//  VisualEffectView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class VisualEffectView: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.visualEffectView.allProperties
    }

    public class override var runtimeType: String {
        return "UIVisualEffectView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIVisualEffectView()
    }
    #endif
}

public class VisualEffectViewProperties: ViewProperties {
    public let effect: AssignablePropertyDescription<VisualEffect>
    
    public required init(configuration: Configuration) {
        effect = configuration.property(name: "effect")
        
        super.init(configuration: configuration)
    }
}
    
