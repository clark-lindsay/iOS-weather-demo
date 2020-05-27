//
//  HTTPClientTests.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/27/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import XCTest
@testable import Weather_Demo

class HTTPClientTests: XCTestCase {
    var systemUnderTest: HTTPClient!
    override func setUpWithError() throws {
        super.setUp()
        systemUnderTest = HTTPClient()
    }

    override func tearDownWithError() throws {
        systemUnderTest = nil
        super.tearDown()
    }

    func testValidCallToServerGetsNoError() {
        let request: ResourceRequest = ResourceRequest(path: "http://localhost:3000/weather/location/new%20york,%20NY", method: .GET)
        let promise = expectation(description: "Completion handler invoked")
        var responseError: Error?
        
        HTTPClient.parseResource(parseable: request, completion: { (parseResult: ParseResult<WeatherData>) -> Void in
            promise.fulfill()
            switch parseResult {
            case.Error(let error):
                responseError = error
            default:
                break
            }
            })
        wait(for: [promise], timeout: 5)
        
        XCTAssertNil(responseError, "The response error was returned non-nil")
    }
}
