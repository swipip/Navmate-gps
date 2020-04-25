//
//  WeatherManager.swift
//  Navmate
//
//  Created by Gautier Billard on 25/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//
import Foundation
import CoreLocation


protocol WeatherManagerDelegate: class {
    func didUpdateWeather(weather: String)
    func didFailedWithError(error: Error)
}

class WeatherManager: NSObject{
    
    static let shared = WeatherManager()
    
    weak var delegate: WeatherManagerDelegate?
    
    let weatherNotification = Notification.Name(K.shared.notificationWeather)
    
    private override init() {
        
    }
    
    let url = "https://api.openweathermap.org/data/2.5/weather?appid=3fbc7ed13bd5f66de97179239a233a7d&units=metric"
    
    func fetchWeather(city: String){
        let urlString = "\(url)&q=\(city)"
        performRequest(urlString: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(url)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if let err = error {
                    print("\(err)")
                }else{
                    if let data = data {
                        let decoder = JSONDecoder()
                        
                        do {
                            let decodedData = try decoder.decode(WeatherData.self, from: data)
                            
                            let weather = WeatherModel(conditionID: decodedData.weather[0].id)
                            
                            
                            
                            DispatchQueue.main.async {
                                let userInfo = ["weather":weather.conditionName]
                                NotificationCenter.default.post(name: self.weatherNotification, object: nil, userInfo: userInfo)
//                                self.delegate?.didUpdateWeather(weather: weather.conditionName)
                            }
                            
                        }catch{
                        }
                    }
                }
                
            }
            task.resume()
        }
    }
    
}

struct WeatherData: Codable {
    var weather: [Weather]
    var main : Main
    var name : String
}
struct Weather: Codable{
    var id: Int
    var main: String
}
struct Main: Codable{
    var temp: Double
    
}
struct WeatherModel{

    let conditionID: Int
    var cityName: String?
    var temperature: Double?
    
//    var temperatureString: String {
//        return String(format: "%.1f", temperature)
//    }

    var conditionName: String {
        switch conditionID {
        case 200...232:
            return "storm"
        case 300...321:
            return "windy"
        case 500...531:
            return "partlyShower"
        case 600...622:
            return "snow"
        case 701...781:
            return "mist"
        case 800:
            return "sunny"
        case 801...804:
            return "partlyCloudy"
        default:
            return "windy"
        }
    }
    
}

