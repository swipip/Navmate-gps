//
//  MonumentManager.swift
//  Navmate
//
//  Created by Gautier Billard on 12/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import MapKit
import CoreLocation

protocol MonumentManagerDelegate: class {
    func didFetchData(monuments: [Monument])
}
struct Monument {
    
    var name: String
    var town: String
    var address: String
    var latitude: Double
    var longitude: Double
    var protection: String
    
}
class MonumentManager: NSObject {
    
    private var monuments = [Monument]()
    private var notificationMonument = Notification.Name(rawValue: K.shared.notificationMonuments)
    
    weak var delegate: MonumentManagerDelegate?
    
    static let shared = MonumentManager()
    
    private override init() {
        super.init()
    }
    
    func getImageName(name: String) -> String{
        if name.contains("Eglise") || name.contains("Église") || name.contains("Croix") || name.contains("Chapelle") {
            
            return "church"
            
        }else if name.contains("Phare") {
            return "lighthouse"
        }else if name.contains("Château") || name.contains("Remparts")  {
            return "castel"
        }else if name.contains("Mosqué") {
            return "mosque"
        }else if name.contains("Menhir") || name.contains("Pierre") || name.contains("Dolmen") {
            return "rocks"
        }else{
            return "historic"
        }
    }
    
    func getData(for region: CLCircularRegion) {
        
        self.monuments.removeAll()
        
        fetchData { (json) in

            let monumentsArray = json["areas"][0]["monuments"].arrayValue
            
            let latitude = monumentsArray.map({$0["Latitude"].doubleValue})
            let longitude = monumentsArray.map({$0["Longitude"].doubleValue})
            
            for (i,latitude) in latitude.enumerated() {
                
                let location = CLLocation(latitude: latitude, longitude: longitude[i])
                
                if region.contains(location.coordinate) {
                    
                    let name = monumentsArray[i]["Monument"].stringValue
                    
                    let protection = monumentsArray[i]["Protection"].stringValue
                    let town = monumentsArray[i]["Commune"].stringValue
                    let address = monumentsArray[i]["Adresse"].stringValue
                    
                    
                    let monument = Monument(name: name, town: town, address: address, latitude: latitude, longitude: longitude[i], protection: protection)
                    self.monuments.append(monument)
                }
                
            }
            
            DispatchQueue.main.async {
                
                let userInfo = ["monuments":self.monuments]
                NotificationCenter.default.post(name: self.notificationMonument, object: nil, userInfo: userInfo)
                
                self.delegate?.didFetchData(monuments: self.monuments)
                
            }
            
        }
    }
    private func fetchData(completion: @escaping (_ json: JSON) -> Void) {
        
        if let userLocation = Locator.shared.getUserLocation() {
            
            var urlString = ""
            var distancetracker: Double = 100000
            
            var clusterDistance = [Int:Double]()
            
            for (_,cluster) in MonumentClusters.clusterCoordinates.enumerated() {
                
                let clusterLoc = CLLocation(latitude: cluster.value.first!, longitude: cluster.value.last!)
                let distance = clusterLoc.distance(from: userLocation)
                let key = cluster.key
                
                if distance < distancetracker {
                    distancetracker = distance
                    urlString = MonumentClusters.clusters[key]!
                }
                
            }
            
            let url = URL(string: urlString)!
            
            Alamofire.request(url, method: .get).validate().responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    DispatchQueue.main.async {
                        completion(json)
                    }
                    
                case .failure(let error):
                    print(error)
                }
                }
            
        }
    }
}
