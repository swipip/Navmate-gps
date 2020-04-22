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
    
    func getData(for region: CLCircularRegion) {
        
        self.monuments.removeAll()
        
        fetchData { (json) in
            for i in 0...json.count {
                let name = json[i]["Monument"].stringValue
                let latitude = json[i]["Lattitude"].doubleValue
                let longitude = json[i]["Longitude"].doubleValue
                let protection = json[i]["Protection"].stringValue
                let town = json[i]["Commune"].stringValue
                let address = json[i]["Adresse"].stringValue
                
                let monument = Monument(name: name, town: town, address: address, latitude: latitude, longitude: longitude, protection: protection)
                
                let monumentLocation = CLLocation(latitude: latitude, longitude: -longitude)
                
                if region.contains(monumentLocation.coordinate) {
                    self.monuments.append(monument)
                }
            }
            
            let userInfo = ["monuments":self.monuments]
            NotificationCenter.default.post(name: self.notificationMonument, object: nil, userInfo: userInfo)
            
            self.delegate?.didFetchData(monuments: self.monuments)
        }
    }
    private func fetchData(completion: @escaping (_ json: JSON) -> Void) {
        
        let url = URL(string: "https://api.jsonbin.io/b/5e9338f9c740b842f2df073b")!
        
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
