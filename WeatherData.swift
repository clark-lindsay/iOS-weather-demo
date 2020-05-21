//
//  WeatherData.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/21/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import Foundation

struct WeatherData: Parsable {
    let temp: Int
    let name: String
    let forecasts: [Forecast]
    var tempLabel: String {
        get {
            return "\(temp)ºF"
        }
    }
    
    static func parse(json: JSONMessage) throws -> Parsable {
        guard let temp = json["currentTemperature"] as? Int,
        let name = json["name"] as? String,
            let forecastMessages = json["forecasts"] as? [JSONMessage] else {
                throw ParseResourceError.ParseError(message: "Missing fields")
        }
        let parsedForecasts = try forecastMessages.reduce(into: [Forecast]()) {
            (accumulator, message) in
            do {
                let forecast = try Forecast.parse(json: message)
                accumulator.append(forecast as! Forecast)
            } catch let error {
                throw error
            }
        }
        return WeatherData(temp: temp, name: name, forecasts: parsedForecasts)
    }
}

