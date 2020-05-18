//
//  ViewController.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/14/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import UIKit

enum ViewState {
    case Loading
    case DisplayingWeather
}

class ViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastList: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var weatherDataModel: WeatherDataModel!
    var viewState: ViewState = .Loading
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.initializeWeatherModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeWeatherModel()
    }
    
    func initializeWeatherModel() {
        weatherDataModel = WeatherDataModel(delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWeather()
    }
    
    func loadWeather() {
        configureViewForState(state: .Loading)
        weatherDataModel.fetchWeatherForLocation(named: "Arvada,CO")
    }
    
    func configureViewForState(state: ViewState) {
        self.viewState = state
        if viewState == .Loading {
            locationLabel.isHidden = true
            temperatureLabel.isHidden = true
            forecastList.isHidden = true
            spinner.isHidden = false
        } else {
            locationLabel.isHidden = false
            temperatureLabel.isHidden = false
            forecastList.isHidden = false
            spinner.isHidden = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension ViewController: WeatherDataDelegate {
    func weatherDataDidChange(newData: [String : AnyObject]?) {
        if let weatherData = newData {
            if let currentTemp: Int = weatherData["currentTemperature"] as? Int {
                temperatureLabel.text = "\(currentTemp)ºF"
            }
            if let locationName: String = weatherData["name"] as? String {
                locationLabel.text = locationName
            }
            forecastList.reloadData()
        }
        configureViewForState(state: .DisplayingWeather)
    }
    
    func errorFetchingWeatherData(error: Error) {
        print("There was an error getting the weather data: \(error)")
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return weatherDataModel.forecasts?.count ?? 0
      }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! ForecastCell
       let forecast = weatherDataModel.forecasts![indexPath.row]
        let day = forecast["day"] as! String
        let high = forecast["high"] as! Int
        let low = forecast["low"] as! Int
        let conditions = forecast["text"] as! String
        cell.forecastDayLabel.text = day
        cell.highTempLabel.text = "High: \(high)ºF"
        cell.lowTempLabel.text = "Low: \(low)ºF"
        cell.conditionsLabel.text = conditions
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           return CGSize(width: view.frame.width - 20, height: 80)
       }
}

