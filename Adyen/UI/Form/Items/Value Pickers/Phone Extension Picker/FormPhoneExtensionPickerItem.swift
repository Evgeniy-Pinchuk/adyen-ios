//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// View Model for a single PhoneExtension.
public struct PhoneExtensionViewModel: CustomStringConvertible, Equatable {

    /// Picker item title.
    /// :nodoc:
    public let title: String

    /// Country phone extension.
    /// :nodoc:
    public let phoneExtension: String

    /// :nodoc:
    public var description: String { title }
}

/// Describes a single phone extension picker item in the list of selectable items.
/// :nodoc:
public typealias PhoneExtensionPickerItem = BasePickerElement<PhoneExtensionViewModel>

/// Describes a picker item.
/// :nodoc:
public final class FormPhoneExtensionPickerItem: BaseFormPickerItem<PhoneExtensionViewModel> {
    
    /// Initializes the picker item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormPhoneExtensionPickerItem` UI style.
    internal init(selectableValues: [PhoneExtensionPickerItem], style: FormTextItemStyle) {
        assert(selectableValues.count > 0)
        let initValue = selectableValues.first(where: { $0.identifier == Locale.current.regionCode }) ?? selectableValues[0]
        super.init(initValue: initValue, selectableValues: selectableValues, style: style)
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
