//
//  WikiManagerCoord.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SwiftyJSON
protocol WikiManagerCoordDelegate: class {
    func errorRetrievingData()
}
class WikiManagerCoord: NSObject {
    
    static let shared = WikiManagerCoord()
    
    weak var delegate: WikiManagerCoordDelegate?
    
    private var imageURL: String?
    
    private override init() {
        
    }
    private func getJsonString(_ response: DataResponse<Any>) {
        let data = response.data
        let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)
    }
    
    func requestInfo(location: CLLocation) {
        
        
        let parameters : [String:String] = [
            "format": "json",
            "list": "geosearch",
            "gscoord": "\(location.coordinate.latitude)|\(location.coordinate.longitude)",
            "prop" : "extracts|pageimages",
            "gslimit": "10",
            "gsradius": "100",
            "action": "query"
        ]
        let wikipediaURl = "https://fr.wikipedia.org/w/api.php"
        
        //https://fr.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=barberton%20daisy&redirects=1&pithumbsize=500&indexpageids
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {

                let jsonData : JSON = JSON(response.result.value!)

                let pageName = jsonData["query"]["geosearch"][0]["title"].stringValue

                if pageName == "" {
                    self.delegate?.errorRetrievingData()
                }else{
                    WikiManager.shared.requestInfo(monument: pageName)
                }
                      
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    
}

