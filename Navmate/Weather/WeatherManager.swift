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
    
    let url = "https://api.openweathermap.org/data/2.5/weather?appid=\(Keys.shared.weather)&units=metric"
    
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
                                
                                print("weather: \(weather)")
                                
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
    
    func check(time: NSDate) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        guard let
            beginNight = formatter.date(from: "20:00"),
            let beginDay = formatter.date(from: "08:00")
            else { return nil }
        
        if time.compare(beginNight) == .orderedDescending { return "night" }
        if time.compare(beginDay) == .orderedDescending { return "day"}
        return "Evening"
    }

    var conditionName: String {
        switch conditionID {
        case 200...232:
            return "storm"
        case 300...321:
            return "windy"
        case 500...531:
            let time = NSDate()
            let day = check(time: time)
            if day == "night" {
                return "shower"
            }else{
               return "shower"
            }
        case 600...622:
            return "snow"
        case 701...781:
            return "mist"
        case 800:
            let time = NSDate()
            let day = check(time: time)
            if day == "night" {
                return "night"
            }else{
               return "sunny"
            }
            
            
        case 801...804:
            return "partlyCloudy"
        default:
            return "windy"
        }
    }
    
}

