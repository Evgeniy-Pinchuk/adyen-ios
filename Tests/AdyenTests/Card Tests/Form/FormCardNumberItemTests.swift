//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {

    var apiClient: APIClientMock!
    var publicKeyProvider: CardPublicKeyProviderMock!
    let supportedCardTypes: [CardType] = [.visa, .masterCard, .americanExpress, .chinaUnionPay, .maestro]
    var cardBrandProvider: BinInfoProvider!

    override func setUp() {
        apiClient = APIClientMock()
        publicKeyProvider = CardPublicKeyProviderMock()
        cardBrandProvider = BinInfoProvider(apiClient: apiClient,
                                            cardPublicKeyProvider: publicKeyProvider,
                                            minBinLength: 11)
    }

    override func tearDown() {
        apiClient = nil
        publicKeyProvider = nil
        cardBrandProvider = nil
    }

    func testInternalBinLookup() {

        let cardTypeLogos = supportedCardTypes.map {
            FormCardNumberItem.CardTypeLogo(url: URL(string: "http://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)
        
        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]
        
        // Initially, all card type logos should be visible.
        XCTAssertEqual(visa.isHidden, false)
        XCTAssertEqual(mc.isHidden, false)
        XCTAssertEqual(amex.isHidden, false)
        XCTAssertEqual(cup.isHidden, false)
        XCTAssertEqual(maestro.isHidden, false)
        
        // When typing unknown combination, all logos should be hidden.
        item.value = "5"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Maestro pattern, only Maestro should be visible.
        item.value = "56"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, false)
        }
        
        // When typing Mastercard pattern, only Mastercard should be visible.
        item.value = "55"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // Clearing the field should bring back both logos.
        item.value = ""
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing VISA pattern, only VISA should be visible.
        item.value = "4"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, false)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Amex pattern, only Amex should be visible.
        item.value = "34"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, false)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing common pattern, all matching cards should be visible.
        item.value = "62"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, false)
            XCTAssertEqual(maestro.isHidden, false)
        }
    }

    func testExternalBinLookupHappyflow() {
        publicKeyProvider.onFetch = { $0(.success("SOME_PUBLIC_KEY")) }
        let mockedBrands = [CardBrand(type: .masterCard)]
        apiClient.mockedResults = [.success(BinLookupResponse(brands: mockedBrands)),
                                   .success(BinLookupResponse(brands: []))]

        let cardTypeLogos = supportedCardTypes.map {
            FormCardNumberItem.CardTypeLogo(url: URL(string: "http://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]

        item.value = "1234567890"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
    }

    func testExternalBinLookupFallback() {
        publicKeyProvider.onFetch = { $0(.success("SOME_PUBLIC_KEY")) }
        apiClient.mockedResults = [.failure(Dummy.error), .failure(Dummy.error)]

        let cardTypeLogos = supportedCardTypes.map {
            FormCardNumberItem.CardTypeLogo(url: URL(string: "http://google.com")!, type: $0)
        }
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, cardTypeLogos: cardTypeLogos)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]

        // When entering PAN, Mastercard should remain visible.
        item.value = "5577000055770004"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }

        // When entering too long PAN, all logos should be hidden.
        item.value = "55770000557700040"
        cardBrandProvider.provide(for: item.value, supportedTypes: supportedCardTypes) { response in
            let brands = response.brands!.map(\.type)
            item.showLogos(for: brands)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
    }
    
    func testLocalizationWithCustomTableName() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], cardTypeLogos: [], localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, localizedString(.cardNumberItemTitle, expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, localizedString(.cardNumberItemPlaceholder, expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(.cardNumberItemInvalid, expectedLocalizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], cardTypeLogos: [], localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, localizedString(LocalizationKey(key: "adyen_card_numberItem_title"), expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, localizedString(LocalizationKey(key: "adyen_card_numberItem_placeholder"), expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_card_numberItem_invalid"), expectedLocalizationParameters))
    }
    
}
