//
//  WikipediaManager.swift
//  Navmate
//
//  Created by Gautier Billard on 19/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//


import UIKit
import SwiftyJSON
import Alamofire

class WikipediaManager: NSObject {
    
    static let shared = WikipediaManager()
    
    private override init() {
        
    }
    
    func requestInfo(monument: String) {
        
        
        let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : monument, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        let wikipediaURl = "https://en.wikipedia.org/w/api.php"
        
        // https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=barberton%20daisy&redirects=1&pithumbsize=500&indexpageids
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {

                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                

                let data = response.data
                
                let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                
                print(jsonString)
                
    //            self.imageView.sd_setImage(with: URL(string: flowerImageURL), completed: { (image, error,  cache, url) in
    //
    //                if let currentImage = self.imageView.image {
    //
    //                    guard let dominantColor = ColorThief.getColor(from: currentImage) else {
    //                        fatalError("Can't get dominant color")
    //                    }
    //
    //
    //                    DispatchQueue.main.async {
    //                        self.navigationController?.navigationBar.isTranslucent = true
    //                        self.navigationController?.navigationBar.barTintColor = dominantColor.makeUIColor()
    //
    //
    //                    }
    //                } else {
    //                    self.imageView.image = self.pickedImage
    //                    self.infoLabel.text = "Could not get information on flower from Wikipedia."
    //                }
    //
    //            })
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    
}

