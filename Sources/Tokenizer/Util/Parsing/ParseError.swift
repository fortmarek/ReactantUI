//
//  ParseError.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

enum ParseError: Error {
    case unexpectedToken(Lexer.Token)
    case message(String)
}

extension ParseError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .unexpectedToken(let token):
            return "Parser - Unexpected token: \(token)"
        case .message(let message):
            return "Parser - \(message)"
        }
    }

    var errorDescription: String? {
        return localizedDescription
    }
}
