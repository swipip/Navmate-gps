//
//  routingManager.swift
//  mapTest2
//
//  Created by Gautier Billard on 14/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import Polyline
import MapKit


protocol RoutingManagerDelegate {
    func didFindRoute(route: Route)
}

class RoutingManager {
    
    var delegate: RoutingManagerDelegate?
    
    func createRoute(geometry: String ,instructions: [String],steps: [Step],summary: Summary) {
        
        let encodedPolyline = Polyline(encodedPolyline: geometry)
        let decodedLocations: [CLLocation]? = encodedPolyline.locations

        var coordinates: [CLLocationCoordinate2D] = []
        
        decodedLocations?.forEach({ (location) in
            coordinates.append(location.coordinate)
        })

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        coordinates.removeLast()
        let upperLayerPolyline = MKPolyline(coordinates: coordinates, count: coordinates.count - 1)
        let polylines = [polyline,upperLayerPolyline]
        if let wayPoints = decodedLocations {
            
            let route = Route(polylines: polylines, wayPoints: wayPoints, steps: steps, summary: summary)
            
            delegate?.didFindRoute(route: route)
            
        }
    }
    
    func getDirections(from source: CLLocationCoordinate2D,to destination: CLLocationCoordinate2D) {
        
        findRoute(from: source, to: destination) { (data) in
            do {
                let json = try JSON(data: data)
                
                //Geometry
                let geometry = json["routes"][0]["geometry"].stringValue
                print(geometry)
                //Summary
                let totalDistance = json["routes"][0]["summary"]["distance"].doubleValue
                let totalDuration = json["routes"][0]["summary"]["duration"].doubleValue
                
                let instructions = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["instruction"].stringValue})
                let type = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["type"].intValue})
                let name = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["name"].stringValue})
                let minWP = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["way_points"][0].intValue})
                let maxWP = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["way_points"][1].intValue})
                let distance = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["distance"].doubleValue})
                let duration = json["routes"][0]["segments"][0]["steps"].arrayValue.map({$0["duration"].doubleValue})
                
                var wayPointsArray: [[Int]] = []
                for i in 0..<minWP.count {
                    
                    wayPointsArray.append([minWP[i],maxWP[i]])
                    
                }
                var exitNumber = [Int]()
                for (i,type) in type.enumerated() {
                    
                    if type == 7 || type == 8 {
                        let exit = json["routes"][0]["segments"][0]["steps"][i]["exit_number"].intValue
                        exitNumber.append(exit)
                        print(exit)
                    }else{
                        exitNumber.append(0)
                    }
                    
                }
                
                var steps = [Step]()
                
                for i in 0..<instructions.count {
                    
                    let step = Step(type: type[i], instruction: instructions[i], name: name[i], wayPoints: wayPointsArray[i], distance: distance[i], exitNumber: exitNumber[i], duration: duration[i])
                    steps.append(step)
                }
                
                let summary = Summary(distance: totalDistance ,duration: totalDuration)
                
                self.createRoute(geometry: geometry, instructions: instructions, steps: steps,summary: summary)
                
            } catch {
                
            }
        }
    }
    
    private func findRoute(from source: CLLocationCoordinate2D,to destination: CLLocationCoordinate2D,completion: @escaping (_ data: Data) -> Void) {
        let url = URL(string: "https://api.openrouteservice.org/v2/directions/driving-car")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8", forHTTPHeaderField: "Accept")
        request.addValue(Keys.shared.openRoute, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //"options":["avoid_features":["highways","tollways"]
        
        let jsonObject: [String:Any] = [
            "coordinates":[
                [source.longitude,source.latitude], //longitude
                [destination.longitude,destination.latitude]  //latitude
            ],
            "preference":"shortest",//shortest
            "options":["avoid_features":
                ["highways"]
            ]
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
            
//            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//            print(jsonString)

            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let _ = response, let data = data {
            //    print(response)
                print(String(data: data, encoding: .utf8) ?? "")
                
                DispatchQueue.main.async {
                    completion(data)
                }
                
              } else {
                print(error ?? "")
              }
            }

            task.resume()
            
        }catch{
            
        }

    }
    
}
