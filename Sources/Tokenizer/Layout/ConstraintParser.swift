//
//  ConstraintParser.swift
//  Pods
//
//  Created by Tadeas Kriz on 4/29/17.
//
//

class BaseParser<ITEM> {
    enum ParseError: Error {
        case unexpectedToken(Lexer.Token)
        case message(String)
    }

    private var tokens: [Lexer.Token]
    private var position: Int = 0

    init(tokens: [Lexer.Token]) {
        self.tokens = tokens
    }

    func parse() throws -> [ITEM] {
        // Reset
        let tokensBackup = tokens
        defer {
            tokens = tokensBackup
            position = 0
        }

        var items = [] as [ITEM]
        while !hasEnded() {
            let currentPosition = position

            let item = try parseSingle()
            items.append(item)

            if let token = peekToken(), currentPosition == position {
                throw ParseError.unexpectedToken(token)
            }
        }
        return items
    }

    func hasEnded() -> Bool {
        return peekToken() == nil
    }

    func parseSingle() throws -> ITEM {
        fatalError("Abstract!")
    }

    func peekToken() -> Lexer.Token? {
        guard position < tokens.count else { return nil }
        return tokens[position]
    }

    func peekNextToken() -> Lexer.Token? {
        guard position < tokens.count - 1 else { return nil }
        return tokens[position + 1]
    }

    func peekNext<T>(_ f: (Lexer.Token) throws -> T?) rethrows -> T? {
        guard let nextToken = peekNextToken() else { return nil }
        position += 1
        defer { position -= 1 }
        return try f(nextToken)
    }

    func popTokens(_ count: Int) {
        position += count
    }

    func popToken() {
        position += 1
    }

    func popLastToken() -> Lexer.Token {
        return tokens.removeLast()
    }
}

class ConstraintParser: BaseParser<Constraint> {
    private let layoutAttribute: LayoutAttribute

    init(tokens: [Lexer.Token], layoutAttribute: LayoutAttribute) {
        self.layoutAttribute = layoutAttribute
        super.init(tokens: tokens)
    }

    override func parseSingle() throws -> Constraint {
        let field = parseField()

        let relation = try parseRelation() ?? .equal

        let type: ConstraintType
        if case .number(let constant)? = peekToken() {
            type = .constant(constant)
            popToken()
        } else {
            let target = parseTarget()
            let targetAnchor = try parseTargetAnchor()

            var multiplier = 1 as Float
            var constant = 0 as Float
            while !constraintEnd(), let modifier = try parseModifier() {
                switch modifier {
                case .multiplied(let by):
                    multiplier *= by
                case .divided(let by):
                    multiplier /= by
                case .offset(let by):
                    constant += by
                case .inset(let by):
                    constant += by * layoutAttribute.insetDirection
                }
            }

            type = .targeted(target: target ?? (targetAnchor != nil ? .this : .parent),
                             targetAnchor: targetAnchor ?? layoutAttribute.targetAnchor,
                             multiplier: multiplier,
                             constant: constant)
        }

        let priority = try parsePriority() ?? .required

        return Constraint(field: field, anchor: layoutAttribute.anchor, type: type, relation: relation, priority: priority)
    }

    private func constraintEnd() -> Bool {
        if hasEnded() {
            return true
        } else if peekToken() == .semicolon {
            popToken()
            return true
        } else {
            return false
        }
    }

    private func parseField() -> String? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .assignment else { return nil }

        popTokens(2)
        return identifier
    }

    private func parseRelation() throws -> ConstraintRelation? {
        guard case .operatorToken(let op)? = peekToken() else { return nil }
        popToken()

        return try ConstraintRelation(op)
    }

    private func parseTarget() -> ConstraintTarget? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() != .parensOpen else { return nil }
        popToken()
        if peekToken() == .colon, case .identifier(let layoutId)? = peekNextToken() {
            popTokens(2)
            // FIXME Add `enum Target { field(String); layoutId(String) }` and return .layoutId here
            return .layoutId(layoutId)
        } else if identifier == "super" {
            return .parent
        } else if identifier == "self" {
            return .this
        } else {
            return .field(identifier)
        }
    }

    private func parseTargetAnchor() throws -> LayoutAnchor? {
        guard peekToken() == .period, case .identifier(let identifier)? = peekNextToken() else { return nil }
        popTokens(2)
        return try LayoutAnchor(identifier)
    }

    private func parseModifier() throws -> ConstraintModifier? {
        guard case .identifier(let identifier)? = peekToken(), peekNextToken() == .parensOpen else { return nil }
        popTokens(2)

        if case .identifier("by")? = peekToken(), peekNextToken() == .colon {
            popTokens(2)
        }

        guard case .number(let number)? = peekToken(), .parensClose == peekNextToken() else {
            throw ConstraintParser.ParseError.message("Modifier `\(identifier)` couldn't be parsed!")
        }
        popTokens(2)

        switch identifier {
        case "multiplied":
            return .multiplied(by: number)
        case "divided":
            return .divided(by: number)
        case "offset":
            return .offset(by: number)
        case "inset":
            return .inset(by: number)
        default:
            throw ConstraintParser.ParseError.message("Unknown modifier `\(identifier)`")
        }
    }

    private func parsePriority() throws -> ConstraintPriority? {
        guard case .at? = peekToken() else { return nil }
        if case .number(let number)? = peekNextToken() {
            popTokens(2)
            return ConstraintPriority.custom(number)
        } else if case .identifier(let identifier)? = peekNextToken() {
            popTokens(2)
            return try ConstraintPriority(identifier)
        } else {
            throw ConstraintParser.ParseError.message("Missing priority value! `@` token followed by \(peekNextToken().map(String.init(describing:)) ?? "none")")
        }
    }
}

public enum TransformedText {
    case text(String)
    indirect case transform(Transform, TransformedText)

    public enum Transform: String {
        case uppercased
        case lowercased
        case localized
        case capitalized
    }
}



class TextParser: BaseParser<TransformedText> {
    override func parseSingle() throws -> TransformedText {
        if peekToken() == .colon {
            let transformIdentifier: String? = peekNext {
                guard case .identifier(let identifier) = $0, peekNextToken() == .parensOpen else { return nil }
                return identifier
            }
            if let identifier = transformIdentifier {
                popTokens(3)
                let lastToken = popLastToken()
                guard lastToken == .parensClose else {
                    throw TextParser.ParseError.message("Unexpected token `\(lastToken)`, expected `)` to be the last token")
                }
                let inner = try parseSingle()
                guard let transform = TransformedText.Transform(rawValue: identifier) else {
                    throw TextParser.ParseError.message("Unknown text transform :\(identifier)")
                }
                return .transform(transform, inner)
            }
        }

        var components = [] as [String]
        while let token = peekToken() {
            popToken()
            switch token {
            case .identifier(let identifier):
                components.append(identifier)
            case .number(let number):
                components.append("\(number)")
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
            case .other(let other):
                components.append(other)
            case .whitespace(let whitespace):
                components.append(whitespace)
            }
        }
        return .text(components.joined())
    }
}