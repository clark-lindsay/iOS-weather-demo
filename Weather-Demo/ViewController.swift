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
    case SearchForWeather
}

class ViewController: UIViewController, UICollectionViewDelegate, LocationManagerDelegate {
    func currentLocationDetermined(placeDescription: [String: String]) {
        if let locality = placeDescription["locality"], let administrativeArae = placeDescription["administrativeArea"] {
            weatherDataModel.fetchWeatherForLocation(named: "\(locality), \(administrativeArae)")
        } else {
            print("This place is un-named, and thus cannot have data fetched for it.")
        }
    }
    
    func unableToDetermineCurrentLocation() {
        print("Unable to determine location.")
        configureViewForState(state: .DisplayingWeather)
    }
    
    
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var locationSearchButton: UIButton!
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchForWeather()
    }
    @IBOutlet weak var locationCancelSearchButton: UIButton!
    @IBAction func cancelSearchButtonPressed(_ sender: Any) {
        configureViewForState(state: .DisplayingWeather)
    }
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var forecastList: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var weatherDataModel: WeatherDataModel!
    var locationManager: LocationManager!
    var locationTapGestureRecognizer: UITapGestureRecognizer!
    var viewState: ViewState = .Loading
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        self.initializeProperties()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initializeProperties()
    }
    
    func initializeProperties() {
        weatherDataModel = WeatherDataModel(delegate: self)
        locationManager = LocationManager(delegate: self)
    }
    
    @objc func locationTapped(_ recognizer: UITapGestureRecognizer) {
        configureViewForState(state: .SearchForWeather)
    }
    
   func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.locationTapped(_:)))
        locationLabel.isUserInteractionEnabled = true
        locationLabel.addGestureRecognizer(labelTap)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabelTap()
        loadWeather()
    }
    
    func searchForWeather() {
        locationSearchTextField.resignFirstResponder()
        let location = locationSearchTextField.text!
        configureViewForState(state: .Loading)
        var locationDescription: [String: String] = [:]
        let locationChunks = location.split(separator: ",")
        locationDescription["locality"] = String(locationChunks[0])
        locationDescription["administrativeArea"] = String(locationChunks[1])
        currentLocationDetermined(placeDescription: locationDescription)
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
            locationSearchTextField.isHidden = true
            locationSearchButton.isHidden = true
            locationCancelSearchButton.isHidden = true
        } else if viewState == .SearchForWeather {
            locationLabel.isHidden = true
            temperatureLabel.isHidden = true
            forecastList.isHidden = true
            locationSearchTextField.isHidden = false
            locationSearchButton.isHidden = false
            locationCancelSearchButton.isHidden = false
            spinner.isHidden = true
            locationSearchTextField.becomeFirstResponder()
        }
        else {
            locationLabel.isHidden = false
            temperatureLabel.isHidden = false
            forecastList.isHidden = false
            spinner.isHidden = true
            locationSearchTextField.isHidden = true
            locationSearchButton.isHidden = true
            locationCancelSearchButton.isHidden = true
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
