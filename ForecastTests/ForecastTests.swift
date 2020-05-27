//
//  ForecastTests.swift
//  ForecastTests
//
//  Created by Clark Lindsay on 5/27/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import XCTest
@testable import Weather_Demo

class ForecastTests: XCTestCase {
    var systemUnderTest: Forecast!

    override func setUpWithError() throws {
        super.setUp()
        systemUnderTest = Forecast(day: "Friday", conditions: "Partly Cloudy", high: 72, low: 60)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        systemUnderTest = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHighLabelIsFormatted() {
        XCTAssert(systemUnderTest.highLabel == "High: 72ºF", "The high temperature label is not formatted correctly.")
    }
    
    func testLowLabelIsFormatted() {
        XCTAssert(systemUnderTest.lowLabel == "Low: 60ºF", "The low temperature label is not formatted correctly.")
    }
    
    func testParsesJSONInfo() {
        let givenInfo: [String: AnyObject] = ["day": "Monday" as AnyObject, "conditions": "Partly Sunny" as AnyObject, "high": 65 as AnyObject, "low": 50 as AnyObject]
        if let parsedForecast = try? Forecast.parse(json: givenInfo) as? Forecast {
            XCTAssertEqual(parsedForecast.day, "Monday", "The day was not parsed correctly.")
            XCTAssertEqual(parsedForecast.conditions, "Partly Sunny", "The conditions were not parsed correctly.")
            XCTAssertEqual(parsedForecast.high, 65, "The high temperature was not parsed correctly.")
            XCTAssertEqual(parsedForecast.low, 50, "The low temperature was not parsed correctly.")
        }
    }
    
    func testParseThrowsError() {
        let givenInfo: [String: AnyObject] = ["day": "Monday" as AnyObject, "high": 65 as AnyObject]
        XCTAssertThrowsError(try Forecast.parse(json: givenInfo))
    }
}
