//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class CardBrandProviderTests: XCTestCase {

    var cardPublicKeyProvider: CardPublicKeyProviderMock!
    var apiClientMock: APIClientMock!
    var sut: BinInfoProvider!

    override func setUp() {
        cardPublicKeyProvider = CardPublicKeyProviderMock()
        apiClientMock = APIClientMock()
        sut = BinInfoProvider(apiClient: apiClientMock,
                              cardPublicKeyProvider: cardPublicKeyProvider,
                              minBinLength: 11)
    }

    override func tearDown() {
        cardPublicKeyProvider = nil
        apiClientMock = nil
        sut = nil
    }

    func testLocalCardTypeFetch() {
        cardPublicKeyProvider.onFetch = {
            XCTFail("Shoul not call APIClient")
            $0(.success(Dummy.publicKey))
        }
        apiClientMock.onExecute = {
            XCTFail("Shoul not call APIClient")
        }

        sut.provide(for: "56", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetch() {
        cardPublicKeyProvider.onFetch = { $0(.success(Dummy.publicKey)) }
        let mockedBrands = [CardBrand(type: .solo)]
        apiClientMock.mockedResults = [.success(BinLookupResponse(brands: mockedBrands))]

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.solo])
        }
    }

    func testLocalCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.error)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }
        sut.provide(for: "56", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

    func testRemoteCardTypeFetchWhenPublicKeyFailure() {
        cardPublicKeyProvider.onFetch = { $0(.failure(Dummy.error)) }
        apiClientMock.onExecute = { XCTFail("Shoul not call APIClient") }

        sut.provide(for: "5656565656565656", supportedTypes: [.masterCard, .visa, .maestro]) { result in
            XCTAssertEqual(result.brands!.map(\.type), [.maestro])
        }
    }

}
