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
    private let notificationMonumentMap = Notification.Name(K.shared.notificationMonumentsMap)
    
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
    enum MonumentSearchOptions {
        case regular, mapDisplay
    }
    func getData(for region: CLCircularRegion, withOption option: MonumentSearchOptions? = .regular ) {
        
        self.monuments.removeAll()
        
        fetchData(region: region, option: option!) { (json) in

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
                if option == .regular {
                    let userInfo = ["monuments":self.monuments]
                    NotificationCenter.default.post(name: self.notificationMonument, object: nil, userInfo: userInfo)
                    
                    self.delegate?.didFetchData(monuments: self.monuments)
                }else if option == .mapDisplay {
                    let monumentsToSend = Array(self.monuments.shuffled().prefix(20))
                    let userInfo = ["monumentsMap":monumentsToSend]
                    NotificationCenter.default.post(name: self.notificationMonumentMap, object: nil, userInfo: userInfo)
                }
            }
            
        }
    }
    private func fetchData(region: CLCircularRegion, option: MonumentSearchOptions,completion: @escaping (_ json: JSON) -> Void) {
        
        var userLocation = CLLocation()
        if option == .regular {
            guard let location = Locator.shared.getUserLocation() else {return}
            userLocation = location
        }else if option == .mapDisplay {
            userLocation = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)
        }
        
        
        
        
        var urlString = ""
        var distancetracker: Double = 100000
        
        for (_,cluster) in MonumentClusters.clusterCoordinates.enumerated() {
            
            let clusterLoc = CLLocation(latitude: cluster.value.first!, longitude: cluster.value.last!)
            let distance = clusterLoc.distance(from: userLocation)
            let key = cluster.key
            
            if distance < distancetracker {
                distancetracker = distance
                urlString = MonumentClusters.clusters[key]!
            }
            
        }
        
        if let url = URL(string: urlString) {
            
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
