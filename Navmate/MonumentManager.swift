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

protocol MonumentManagerDelegate {
    func didFetchData(monuments: [Monument])
}
struct Monument {
    
    var name: String
    var latitude: Double
    var longitude: Double
    var protection: String
    
}
class MonumentManager {
    
    private var monuments = [Monument]()
    
    var delegate: MonumentManagerDelegate?
    
    func getData() {
        fetchData { (json) in
            for i in 0...json.count {
                let name = json[i]["Monument"].stringValue
                let latitude = json[i]["Lattitude"].doubleValue
                let longitude = json[i]["Longitude"].doubleValue
                let protection = json[i]["Protection"].stringValue
                
                let monument = Monument(name: name, latitude: latitude, longitude: longitude, protection: protection)
                
                self.monuments.append(monument)
            }
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
