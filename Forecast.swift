//
//  Forecast.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/21/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import Foundation

struct Forecast: Parsable {
    let day: String
    let conditions: String
    let high: Int
    let low: Int
    
    var highLabel: String {
        get {
            return "High: \(high)ºF"
        }
    }
    var lowLabel: String {
        get {
            return "Low: \(low)ºF"
        }
    }
    
    static func parse(json: JSONMessage) throws -> Parsable {
        guard let day = json["day"] as? String,
        let high = json["high"] as? Int,
        let low = json["low"] as? Int,
            let conditions = json["conditions"] as? String else {
                throw ParseResourceError.ParseError(message: "Missing fields")
        }
        return Forecast(day: day, conditions: conditions, high: high, low: low)
    }
}
