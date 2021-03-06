//
//  XSDCommand.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Generator
import Tokenizer
import Foundation
import SwiftCLI

final class XSDCommand: Command {
    let name = "xsd"
    let shortDescription = "Generate XSD file"

    let outputFile = Key<String>("--outputFile")

    public func execute() throws {
        guard let outputFile = outputFile.value, let outputPathURL = URL(string: "file://\(outputFile)") else {
            throw GenerateCommandError.ouputFileInvalid
        }

        let file = XSDResolver().resolve()

        try XSDSerializer(root: file).serialize().write(to: outputPathURL, atomically: true, encoding: .utf8)
    }
}
