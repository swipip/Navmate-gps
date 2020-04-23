//
//  Route.swift
//  mapTest2
//
//  Created by Gautier Billard on 15/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

struct Route {
    
    var polylines: [MKPolyline]
    var wayPoints: [CLLocation]
    var steps: [Step]
    var summary: Summary
    
}
struct Step {
    
    var type: Int
    var instruction: String
    var name: String
    var wayPoints: [Int]
    var distance: Double
    var exitNumber: Int
    var duration: Double
    
}
struct Summary {
    
//    var destination: String
//    var destinationType: DestinationType
    var distance: Double
    var duration: Double
    var preference: String
    var mode: String
    var avoid: [String]
    
}
//enum DestinationType {
//    case regular,monument,pointOfInterest
//}
