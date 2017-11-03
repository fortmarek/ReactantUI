//
//  PreviewController.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class PreviewController: ControllerBase<Void, PreviewRootView> {
    struct Parameters {
        let typeName: String
        let view: UIView
    }

    private let parameters: Parameters

    init(parameters: Parameters) {
        self.parameters = parameters

        super.init(title: "Previewing: \(parameters.typeName)",
            root: PreviewRootView(previewing: parameters.view))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if os(iOS)
        navigationController?.hidesBarsOnTap = true
        #endif
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        #if os(iOS)
        navigationController?.hidesBarsOnTap = false
        #endif
    }
}
