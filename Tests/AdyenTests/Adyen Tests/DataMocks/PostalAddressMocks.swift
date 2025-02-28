//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

enum PostalAddressMocks {
    static let newYorkPostalAddress = PostalAddress(city: "New York",
                                                    country: "US",
                                                    houseNumberOrName: "14",
                                                    postalCode: "10019",
                                                    stateOrProvince: "NY",
                                                    street: "8th Ave",
                                                    apartment: nil)
    static let losAngelesPostalAddress = PostalAddress(city: "Los Angeles",
                                                       country: "US",
                                                       houseNumberOrName: "3310",
                                                       postalCode: "90040",
                                                       stateOrProvince: "CA",
                                                       street: "Garfield Ave",
                                                       apartment: nil)
}
