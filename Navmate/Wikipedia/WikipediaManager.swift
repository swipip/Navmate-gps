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
protocol WikiManagerDelegate: class {
    func didFindData(wiki: WikiObject)
}
struct WikiObject {
    
    var title: String
    var description: String
    var image: UIImage?
    var url: String
}
class WikiManager: NSObject {
    
    static let shared = WikiManager()
    
    weak var delegate: WikiManagerDelegate?
    
    private var imageURL: String?
    
    private override init() {
        
    }
    
    private func fetchImage(completion: @escaping (UIImage?)  -> Void) {
        
        if let urlString = self.imageURL {
            
            if let url = URL(string: urlString) {
                let urlSession = URLSession(configuration: .default)
                
                let task = urlSession.dataTask(with: url) { (data, response, error) in
                    if let err = error {
                        print("\(#function) error while loading image of type :\(err)")
                        return
                    }
                    DispatchQueue.main.async {
                        if let data = data {
                            let image = UIImage(data: data)!
                            completion(image)
                        }else{
                            print("\(#function) could not load the image")
                            return
                        }
                    }
                }
                task.resume()
            }
        }
    }
    
    func requestInfo(monument: String) {
        
        
        let parameters : [String:String] = ["format" : "json", "action" : "query", "prop" : "extracts|pageimages", "exintro" : "", "explaintext" : "", "titles" : monument, "redirects" : "1", "pithumbsize" : "500", "indexpageids" : ""]
        let wikipediaURl = "https://fr.wikipedia.org/w/api.php"
        
        // https://fr.wikipedia.org/w/api.php?format=json&action=query&prop=extracts|pageimages&exintro=&explaintext=&titles=barberton%20daisy&redirects=1&pithumbsize=500&indexpageids
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            if response.result.isSuccess {

                print(wikipediaURl)
                
                let jsonData : JSON = JSON(response.result.value!)
                
                let pageid = jsonData["query"]["pageids"][0].stringValue
                
                let description = jsonData["query"]["pages"][pageid]["extract"].stringValue
                self.imageURL = jsonData["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                
                
                var wikiObject: WikiObject!
                
                DispatchQueue.main.async {
                    let _ = self.fetchImage(completion: { (image) in
                        if let image = image {
                            
                            let encodedName = monument.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                            print(encodedName!)
                            
//                            let url = "https://fr.wikipedia.org/wiki/\(monument.replacingOccurrences(of: " ", with: "_"))"
                             let url = "https://fr.wikipedia.org/wiki/\(encodedName!)"
                            
                            wikiObject = WikiObject(title: monument, description: description,image: image, url: url)
                            self.delegate?.didFindData(wiki: wikiObject)
                            
                            let name = Notification.Name(K.shared.notificationWikiPedia)
                            let userInfo = ["wikipedia":wikiObject]
                            NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo as! [AnyHashable : WikiObject])
                            
                        }else{
                            let encodedName = monument.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                            print(encodedName!)
//                            let url = "https://fr.wikipedia.org/wiki/\(monument.replacingOccurrences(of: " ", with: "_"))"
                            let url = "https://fr.wikipedia.org/wiki/\(encodedName!)"
                            wikiObject = WikiObject(title: monument, description: description, url: url)
                            self.delegate?.didFindData(wiki: wikiObject)
                        }
                    })
                }
                
                                let data = response.data

                let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String

                print(jsonString)

                
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }

    
}

