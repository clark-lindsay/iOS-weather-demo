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

class ViewController: UIViewController, UICollectionViewDelegate {
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
    @IBOutlet weak var loadingLabel: UILabel!
    
    var weatherDataModel: WeatherDataModel!
    var locationManager: LocationManager!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationLabelTap()
        loadWeather()
    }
    
    func setupLocationLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.locationLabelTapped(_:)))
        locationLabel.isUserInteractionEnabled = true
        locationLabel.addGestureRecognizer(labelTap)
    }
    
    @objc func locationLabelTapped(_ recognizer: UITapGestureRecognizer) {
        configureViewForState(state: .SearchForWeather)
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
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {(context) -> Void in self.forecastList.collectionViewLayout.invalidateLayout()}, completion: nil)
    }
    
    func configureViewForState(state: ViewState) {
        self.viewState = state
        if viewState == .Loading {
            locationLabel.isHidden = true
            temperatureLabel.isHidden = true
            forecastList.isHidden = true
            spinner.isHidden = false
            loadingLabel.isHidden = false
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
            loadingLabel.isHidden = true
            locationSearchTextField.becomeFirstResponder()
        }
        else {
            locationLabel.isHidden = false
            temperatureLabel.isHidden = false
            forecastList.isHidden = false
            spinner.isHidden = true
            loadingLabel.isHidden = true
            locationSearchTextField.isHidden = true
            locationSearchButton.isHidden = true
            locationCancelSearchButton.isHidden = true
        }
    }
}

extension ViewController: WeatherDataDelegate {
    func weatherDataDidChange(newData: WeatherData?) {
        if let weatherData = newData {
            temperatureLabel.text = "\(weatherData.tempLabel)"
            locationLabel.text = weatherData.name
            forecastList.reloadData()
            configureViewForState(state: .DisplayingWeather)
        }
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
        cell.forecastDayLabel.text = forecast.day
        cell.highTempLabel.text = forecast.highLabel
        cell.lowTempLabel.text = forecast.lowLabel
        cell.conditionsLabel.text = forecast.conditions
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           let regularHorizontalSizeClassCellWidth: CGFloat = 150
           let regularHorizontalSizeClassCellHeight: CGFloat = 150
           let compactHorizontalSizeClassCellHeight: CGFloat = 80
           
           let viewWidth = view.frame.width
           let layout = forecastList.collectionViewLayout as! UICollectionViewFlowLayout
           layout.minimumInteritemSpacing = 0
           let horizontalSizeClass = traitCollection.horizontalSizeClass
           let verticalSizeClass = traitCollection.verticalSizeClass
           
           if horizontalSizeClass == .compact && verticalSizeClass == .regular {
               return CGSize(width: viewWidth, height: compactHorizontalSizeClassCellHeight)
           } else if verticalSizeClass == .compact {
               let cellSize = viewWidth / 5
               return CGSize(width: cellSize, height: cellSize)
           } else {
               return CGSize(width: regularHorizontalSizeClassCellWidth, height: regularHorizontalSizeClassCellHeight)
           }
       }
}

extension ViewController: LocationManagerDelegate {
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
}
