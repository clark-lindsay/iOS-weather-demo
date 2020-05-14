//
//  ViewController.swift
//  Weather-Demo
//
//  Created by Clark Lindsay on 5/14/20.
//  Copyright © 2020 Clark Lindsay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "http://localhost:3000/weather/location/Arvada,CO")
        let session = URLSession.shared
        let task = session.dataTask(
            with: url!, completionHandler: {(data, response, error) in
                if (data != nil) {
                    let json: NSDictionary?
                    do { json = try
                        JSONSerialization.jsonObject( with: data!, options: JSONSerialization.ReadingOptions()
                        ) as? NSDictionary
                        DispatchQueue.main.async {
                            let currentTemp: Int = json!.object(forKey: "currentTemperature") as! Int
                            let locationName: String = json!.object(forKey: "name") as! String
                            self.temperatureLabel.text = "\(currentTemp)ºF"
                            self.locationLabel.text = locationName
                        }
                    } catch let e {
                        print("Error retrieving weather data: \(e)") }
                } })
        task.resume()
        // Do any additional setup after loading the view.
    }


}

