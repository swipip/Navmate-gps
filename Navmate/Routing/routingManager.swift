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
    func didnotFindRoute()
}

class RoutingManager {
    
    var delegate: RoutingManagerDelegate?
    var jsonData: Data?
    
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
            
            DispatchQueue.main.async {
                self.delegate?.didFindRoute(route: route)
            }
            
            
        }
    }
    
    func getDirections(from source: CLLocationCoordinate2D,to destination: CLLocationCoordinate2D ,mode: String, preference: String, avoid: [String]) {
        
//        jsonData = serializeJSON()
        
        findRoute(from: source, to: destination,mode: mode,preference: preference, avoid: avoid) { (data) in
            do {
                let json = try JSON(data: data)
                
                //Geometry
                let geometry = json["routes"][0]["geometry"].stringValue
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
                    }else{
                        exitNumber.append(0)
                    }
                    
                }
                
                var steps = [Step]()
                
                for i in 0..<instructions.count {
                    
                    let step = Step(type: type[i], instruction: instructions[i], name: name[i], wayPoints: wayPointsArray[i], distance: distance[i], exitNumber: exitNumber[i], duration: duration[i])
                    steps.append(step)
                }
                
                let summary = Summary(distance: totalDistance ,duration: totalDuration, preference: preference,mode: mode, avoid: avoid)
                
                if steps.count == 0 {
                    self.delegate?.didnotFindRoute()
                }else{
                    self.createRoute(geometry: geometry, instructions: instructions, steps: steps,summary: summary)
                }
                
            } catch {
                
            }
        }
    }
    func serializeJSON(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D,mode: String, preference: String, avoid: [String]) -> Data?{
        
        let sourceLatitude = source.latitude
        let sourceLongitude = source.longitude
        
        let destinationLatitude = destination.latitude
        let desitnationLongitude = destination.longitude
        
        var avoidFeatures: AvoidFeatures?
        var query: RouteQueryModel!
        
        
        if mode == "driving-car" {
            avoidFeatures = AvoidFeatures(avoid_features: avoid)
            query = RouteQueryModel(options: avoidFeatures, preference: preference, coordinates: [[sourceLongitude,sourceLatitude],[desitnationLongitude,destinationLatitude]])
        }else{
            query = RouteQueryModel(preference: preference, coordinates: [[sourceLongitude,sourceLatitude],[desitnationLongitude,destinationLatitude]])
        }
        
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(query)

//            let jsonString = NSString(data: json as Data, encoding: String.Encoding.utf8.rawValue)! as String
//
//            print(jsonString)
            
            return json
        }catch{
            return nil
        }
    }
    private func findRoute(from source: CLLocationCoordinate2D,to destination: CLLocationCoordinate2D,mode: String, preference: String, avoid: [String],completion: @escaping (_ data: Data) -> Void) {
        let url = URL(string: "https://api.openrouteservice.org/v2/directions/\(mode)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8", forHTTPHeaderField: "Accept")
        request.addValue(Keys.shared.openRoute, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        //"options":["avoid_features":["highways","tollways"]
        
        if let jsonData = serializeJSON(from: source, to: destination,mode: mode, preference: preference, avoid: avoid) {
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let response = response, let data = data {
            //    print(response)
//                print(String(data: data, encoding: .utf8) ?? "")
                
                DispatchQueue.main.async {
                    completion(data)
                }
                
              } else {
                print(error ?? "")
              }
            }

            task.resume()
            
        }
    }
    
}
