//
//  LocationManager.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/19/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate {
    func currentLocationDetermined(placeDescription: [String: String])
    func unableToDetermineCurrentLocation()
}

class LocationManager : NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    var delegate: LocationManagerDelegate!
    
    required init(delegate: LocationManagerDelegate) {
        super.init()
        self.delegate = delegate
        locationManager.delegate = self
    }
    
    func determineCurrentLocation() {
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            delegate.unableToDetermineCurrentLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization: CLAuthorizationStatus) {
        determineCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate.unableToDetermineCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let latestLocation: CLLocation = locations.first as CLLocation? {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(latestLocation, completionHandler: {
                [weak self] (results, error) -> Void in
                if let firstResult: CLPlacemark = results!.first as CLPlacemark? {
                    let placeDescription = createDescriptionOf(place: firstResult)
                    self?.locationManager.stopUpdatingLocation()
                    self?.delegate.currentLocationDetermined(placeDescription: placeDescription)
                } else {
                    self?.delegate.unableToDetermineCurrentLocation()
                }
            })
        } else {
            delegate.unableToDetermineCurrentLocation()
        }
    }
}

func createDescriptionOf(place: CLPlacemark) -> [String: String] {
    var result = [String: String]()
    if let name = place.name {
        result["name"] = name
    }
    if let thoroughfare = place.thoroughfare {
        result["thoroughfare"] =  thoroughfare
    }
    if let locality = place.locality {
        result["locality"] = locality
    }
    if let administrativeArea = place.administrativeArea {
        result["administrativeArea"] = administrativeArea
    }
    if let postalCode = place.postalCode {
        result["postalCode"] = postalCode
    }
    if let countryCode = place.isoCountryCode {
        result["countryCode"] = countryCode
    }
    return result
}
