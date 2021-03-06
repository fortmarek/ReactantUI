//
//  MainWireframe.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Reactant

final class MainWireframe: Wireframe {

    func entrypoint() -> UIViewController {
        return UINavigationController(rootViewController: exampleSelection())
    }

    func exampleSelection() -> ExampleSelectionController {
        return create { provider in
            let reactions = ExampleSelectionController.Reactions(
                exampleSelected: {
                    switch $0 {
                    case .playground:
                        provider.navigation?.push(controller: self.playground())
                    case .plainTableView:
                        provider.navigation?.push(controller: self.plainTableViewController())
                    case .stackView:
                        provider.navigation?.push(controller: self.stackViewController())
                    case .progressView:
                        provider.navigation?.push(controller: self.progressViewController())
                    }
                }
            )

            return ExampleSelectionController(reactions: reactions)
        }
    }

    private func playground() -> UIViewController {
        return ViewController()
    }

    private func plainTableViewController() -> PlainTableViewController {
        return PlainTableViewController()
    }

    private func stackViewController() -> StackViewController {
        return StackViewController()
    }

    private func progressViewController() -> ProgressViewController {
        return ProgressViewController()
    }
}
