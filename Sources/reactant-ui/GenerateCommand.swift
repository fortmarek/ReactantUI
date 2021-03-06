//
//  GenerateCommand.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/02/2018.
//
import Generator
import Tokenizer
import Foundation
import xcproj
import SwiftCLI

public enum GenerateCommandError: Error, LocalizedError {
    case inputPathInvalid
    case ouputFileInvalid
    case XCodeProjectPathInvalid
    case cannotReadXCodeProj
    case invalidType(String)
    case tokenizationError(path: String, error: Error)
    case invalidSwiftVersion

    public var localizedDescription: String {
        switch self {
        case .inputPathInvalid:
            return "Input path is invalid."
        case .ouputFileInvalid:
            return "Output file path is invalid."
        case .XCodeProjectPathInvalid:
            return "xcodeproj path is invalid."
        case .cannotReadXCodeProj:
            return "Cannot read xcodeproj."
        case .invalidType(let path):
            return "Invalid Component type at path: \(path) - do not use keywords.";
        case .tokenizationError(let path, let error):
            return "Tokenization error in file: \(path), error: \(error.localizedDescription)"
        case .invalidSwiftVersion:
            return "Invalid Swift version"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}

class GenerateCommand: Command {

    static let forbiddenNames = ["RootView", "UIView", "UIViewController", "self", "switch",
                                 "if", "else", "guard", "func", "class", "ViewBase", "ControllerBase", "for"]

    let name = "generate"
    let shortDescription = "Generate Swift UI code from XMLs"
    let enableLive = Flag("--enable-live")

    let xcodeProjectPath = Key<String>("--xcodeprojPath")
    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")
    let swiftVersionParameter = Key<String>("--swift")

    public func execute() throws {
        var output: [String] = []

        guard let inputPath = inputPath.value, let inputPathURL = URL(string: "file://\(inputPath)") else {
            throw GenerateCommandError.inputPathInvalid
        }

        guard let outputFile = outputFile.value, let outputPathURL = URL(string: "file://\(outputFile)") else {
            throw GenerateCommandError.ouputFileInvalid
        }

        let rawSwiftVersion = swiftVersionParameter.value ?? "4.1" // use 4.1 as default
        guard let swiftVersion = SwiftVersion(raw: rawSwiftVersion) else {
            throw GenerateCommandError.invalidSwiftVersion
        }

        let minimumDeploymentTarget = try self.minimumDeploymentTarget()

        let uiXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let uiFiles = uiXmlEnumerator?.compactMap { $0 as? String }.filter { $0.hasSuffix(".ui.xml") }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        let styleXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let styleFiles = styleXmlEnumerator?.compactMap { $0 as? String }.filter { $0.hasSuffix(".styles.xml") }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        var stylePaths = [] as [String]
        for (index, path) in styleFiles.enumerated() {
            output.append("// Generated from \(path)")
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)
            let group: StyleGroup = try xml["styleGroup"].value()
            stylePaths.append(path)
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive.value,
                                                       swiftVersion: swiftVersion)
            output.append(try StyleGenerator(group: group, configuration: configuration).generate(imports: index == 0))
        }

        var componentTypes: [String] = []
        var componentDefinitions: [String: ComponentDefinition] = [:]
        var imports: Set<String> = []
        for path in uiFiles {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)

            let node = xml["Component"].element!
            var definition: ComponentDefinition
            do {
                if let type: String = xml["Component"].value(ofAttribute: "type") {
                    definition = try ComponentDefinition(node: node, type: type)
                } else {
                    definition = try ComponentDefinition(node: node, type: componentType(from: path))
                }
                if GenerateCommand.forbiddenNames.contains(definition.type) {
                    throw GenerateCommandError.invalidType(path)
                }
            } catch let error {
                throw GenerateCommandError.tokenizationError(path: path, error: error)
            }
            componentTypes.append(contentsOf: definition.componentTypes)
            componentDefinitions[path] = definition
            imports.formUnion(definition.requiredImports)
            imports.formUnion(definition.styles.map { $0.parentModuleImport })
        }

        output.append("""
              import UIKit
              import Reactant
              import SnapKit
              """)

        if enableLive.value {
            output.append(ifSimulator(swiftVersion: swiftVersion, commands: "import ReactantLiveUI"))
        }
        for imp in imports {
            output.append("import \(imp)")
        }

        for (path, rootDefinition) in componentDefinitions {
            output.append("// Generated from \(path)")
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget, localXmlPath: path, isLiveEnabled: enableLive.value, swiftVersion: swiftVersion)
            for definition in rootDefinition.componentDefinitions {
                output.append(try UIGenerator(definition: definition, configuration: configuration).generate(imports: false))
            }
        }


        if enableLive.value {
            if swiftVersion < .swift4_1 {
                output.append("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
            } else {
                output.append("#if targetEnvironment(simulator)")
            }
            output.append("""
                      struct GeneratedReactantLiveUIConfiguration: ReactantLiveUIConfiguration {
                      let rootDir = \"\(inputPath)\"
                      let commonStylePaths: [String] = [
                  """)
            for path in stylePaths {
                output.append("        \"\(path)\",")
            }
            output.append("    ]")

            if componentTypes.isEmpty {
                output.append("    let componentTypes: [String: UIView.Type] = [:]")
            } else {
                output.append("    let componentTypes: [String: UIView.Type] = [")
                // filter out empty component types - these components are initialized in code, so they should already be included if they use RUI
                for type in Set(componentTypes) {
                    output.append("        \"\(type)\": \(type).self,")
                }
                output.append("    ]")
            }
            output.append("""
                  }
                  #endif
                  """)
        }

        output.append("func activateLiveReload(in window: UIWindow) {")
        if enableLive.value {
            output.append(ifSimulator(swiftVersion: swiftVersion, commands:"     ReactantLiveUIManager.shared.activate(in: window, configuration: GeneratedReactantLiveUIConfiguration())"))
        }
        output.append("}")

        try output.joined(separator: "\n").write(to: outputPathURL, atomically: true, encoding: .utf8)
    }

    private func minimumDeploymentTarget() throws -> Int {
        guard let xcodeProjectPathsString = xcodeProjectPath.value, let xcprojpath = URL(string: xcodeProjectPathsString) else {
            throw GenerateCommandError.XCodeProjectPathInvalid
        }

        guard let project = try? XcodeProj(pathString: xcprojpath.absoluteURL.path) else {
            throw GenerateCommandError.cannotReadXCodeProj
        }

        return project.pbxproj.objects.buildConfigurations.values
            .compactMap { config -> Substring? in
                let value = (config.buildSettings["TVOS_DEPLOYMENT_TARGET"] ?? config.buildSettings["IPHONEOS_DEPLOYMENT_TARGET"]) as? String

                return value?.split(separator: ".").first
            }
            .compactMap { Int(String($0)) }.reduce(50) { previous, new in
                return previous < new ? previous : new
        }
    }

    private func ifSimulator(swiftVersion: SwiftVersion, commands: String) -> String {
        if swiftVersion >= .swift4_1 {
            return """
            #if targetEnvironment(simulator)
            \(commands)
            #endif
            """
        } else {
            return """
            #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))
            \(commands)
            #endif
            """
        }
    }
}
