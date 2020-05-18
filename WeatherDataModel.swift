//
//  WeatherDataModel.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/14/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import Foundation

protocol WeatherDataDelegate {
    func weatherDataDidChange(newData: [String: AnyObject]?)
    func errorFetchingWeatherData(error: Error)
}

class WeatherDataModel {
    private var weatherDataDelegate: WeatherDataDelegate?
    
    var weatherData: [String: AnyObject]? = [:] {
        didSet {
            weatherDataDelegate?.weatherDataDidChange(newData: weatherData)
        }
    }
    var forecasts: [[String: AnyObject]]? {
        get {
            if let forecastList = weatherData?["forecasts"] as? [[String: AnyObject]] {
                return forecastList
            } else {
                return nil
            }
        }
    }
    
    init(delegate: WeatherDataDelegate) {
        weatherDataDelegate = delegate
    }
    
    func fetchWeatherForLocation(named location: String) {
        let encodedLocation = location.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: "http://localhost:3000/weather/location/\(encodedLocation!)")
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {
            [weak self]
            (data, response, error) in
            if (data != nil) {
                let json: [String: AnyObject]?
                do { json = try
                    JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
                    self?.weatherFetchComplete(results: json!, error: nil)
                } catch let error {
                    self?.weatherFetchComplete(results: nil, error: error)
                }
            }
        })
        task.resume()
    }
    
    func weatherFetchComplete(results: [String: AnyObject]?, error: Error?) {
        DispatchQueue.main.async {
            if let fetchError = error {
                self.weatherDataDelegate?.errorFetchingWeatherData(error: fetchError)
            } else {
                if let weatherResults = results {
                    self.weatherData = weatherResults
                }
            }
            
        }
    }
}
