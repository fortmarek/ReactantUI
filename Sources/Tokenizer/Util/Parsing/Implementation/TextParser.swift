//
//  TextParser.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

class TextParser: BaseParser<TransformedText> {

    override func parseSingle() throws -> TransformedText {
        if peekToken() == .colon {
            let transformIdentifier: String? = peekNext {
                guard case .identifier(let identifier) = $0, peekNextToken() == .parensOpen else { return nil }
                return identifier
            }
            if let identifier = transformIdentifier {
                try popTokens(3)
                let lastToken = try popLastToken()
                guard lastToken == .parensClose else {
                    throw ParseError.message("Unexpected token `\(lastToken)`, expected `)` to be the last token")
                }
                let inner = try parseSingle()
                guard let transform = TransformedText.Transform(rawValue: identifier) else {
                    throw ParseError.message("Unknown text transform :\(identifier)")
                }
                return .transform(transform, inner)
            }
        }

        var components = [] as [String]
        while let token = peekToken() {
            try popToken()
            switch token {
            case .identifier(let identifier):
                components.append(identifier)
            case .number(_, let original):
                components.append(original)
            case .parensOpen:
                components.append("(")
            case .parensClose:
                components.append(")")
            case .assignment:
                components.append("=")
            case .operatorToken(let op):
                components.append(op)
            case .colon:
                components.append(":")
            case .semicolon:
                components.append(";")
            case .period:
                components.append(".")
            case .at:
                components.append("@")
            case .comma:
                components.append(",")
            case .other(let other):
                components.append(other)
            case .whitespace(let whitespace):
                components.append(whitespace)
            }
        }
        return .text(components.joined())
    }
}
