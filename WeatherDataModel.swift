//
//  WeatherDataModel.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/14/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import Foundation

protocol WeatherDataDelegate {
    func weatherDataDidChange(newData: WeatherData?)
    func errorFetchingWeatherData(error: Error)
}

class WeatherDataModel {
    private var weatherDataDelegate: WeatherDataDelegate?
    
    var weatherData: WeatherData? {
        didSet {
            weatherDataDelegate?.weatherDataDidChange(newData: weatherData)
        }
    }
    var forecasts: [Forecast]? {
        get {
            return weatherData?.forecasts
        }
    }
    
    init(delegate: WeatherDataDelegate) {
        weatherDataDelegate = delegate
    }
    
    func fetchWeatherForLocation(named location: String) {
        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let path = "http://localhost:3000/weather/location/\(encodedLocation!)"
        let parseableResource = ResourceRequest(path: path, method: .GET)
        HTTPClient.parseResource(parseable: parseableResource, completion: {
            [weak self]
            (parseResult: ParseResult<WeatherData>) -> Void in
            switch parseResult {
            case .Error(let error):
                self?.weatherFetchComplete(results: nil, error: error)
            case .Result(let weatherData):
                self?.weatherFetchComplete(results: weatherData, error: nil)
            }
        })
    }
    
    func weatherFetchComplete(results: WeatherData?, error: Error?) {
        DispatchQueue.main.async {
            if let fetchError = error {
                self.weatherDataDelegate?.errorFetchingWeatherData(error: fetchError)
            } else {
                self.weatherData = results
            }
            
        }
    }
}
