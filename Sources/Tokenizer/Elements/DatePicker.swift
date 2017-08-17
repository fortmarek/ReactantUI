import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.datePicker.allProperties
    }

    public class override var runtimeType: String {
        return "UIDatePicker"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIDatePicker()
    }
    #endif
}

public class DatePickerProperties: ViewProperties {
    public let minuteInterval: AssignablePropertyDescription<Int>
    public let mode: AssignablePropertyDescription<DatePickerMode>
    
    public required init(configuration: PropertyContainer.Configuration) {
        minuteInterval = configuration.property(name: "minuteInterval")
        mode = configuration.property(name: "mode", swiftName: "datePickerMode", key: "datePickerMode")
        super.init(configuration: configuration)
    }
}
