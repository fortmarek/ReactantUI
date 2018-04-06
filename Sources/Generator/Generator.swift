import Foundation
import Tokenizer

public struct GeneratorConfiguration {
    public let minimumMajorVersion: Int
    public let localXmlPath: String
    public let isLiveEnabled: Bool
    
    public init(minimumMajorVersion: Int, localXmlPath: String, isLiveEnabled: Bool) {
        self.minimumMajorVersion = minimumMajorVersion
        self.localXmlPath = localXmlPath
        self.isLiveEnabled = isLiveEnabled
    }
}

public struct GeneratorError: Error, LocalizedError {
    public let message: String

    public var errorDescription: String? {
        return message
    }

    public var localizedDescription: String {
        return message
    }
}

public class Generator {

    let configuration: GeneratorConfiguration

    var nestLevel: Int = 0

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }
    
    var output = ""

    func generate(imports: Bool) throws -> String {
        return output
    }

    func l(_ line: String = "") {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line + "\n")
    }

    func l(_ line: String = "", _ f: () throws -> Void) throws {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line)

        nestLevel += 1
        output.append(" {" + "\n")
        try f()
        nestLevel -= 1
        l("}")
    }

    func l(_ line: String = "", _ f: () -> Void) {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line)

        nestLevel += 1
        output.append(" {" + "\n")
        f()
        nestLevel -= 1
        l("}")
    }
    
    func ifSimulator(_ commands: String) -> String {
        // FIXME use targetEnvironment(simulator)
        return """
        #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))
        \(commands)
        #endif
        """
    }
}
