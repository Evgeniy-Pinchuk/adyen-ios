//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// So that any `Bundle` instance will inherit the `adyen` scope.
/// :nodoc:
extension Bundle: AdyenCompatible {}

/// Adds helper functionality to any `Bundle` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: Bundle {
    
    /// Enables any `Bundle` instance to check whether a certain scheme is configured in the Info.plist or not.
    /// :nodoc:
    public func isSchemeConfigured(_ scheme: String) -> Bool {
        guard let configuredSchemes = base.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] else {
            return false
        }
        guard configuredSchemes.contains(where: { $0.lowercased() == scheme.lowercased() }) else {
            return false
        }
        return true
    }
    
}
