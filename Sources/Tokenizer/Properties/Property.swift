#if ReactantRuntime
import UIKit
#endif

public protocol Property {
    var attributeName: String { get }

    func application(on target: String) -> String

    #if SanAndreas
    func dematerialize() -> MagicAttribute
    #endif
    
    #if ReactantRuntime
    func apply(on object: AnyObject) throws -> Void
    #endif
}

public protocol TypedProperty: Property {
    associatedtype ValueType: SupportedPropertyType

    var value: ValueType { get set }
}
