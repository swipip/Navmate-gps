//
//  RouteRequest.swift
//  Navmate
//
//  Created by Gautier Billard on 23/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import CoreLocation

struct RouteRequest {
    
    var destinationName: String
    var destination: CLLocation
    var destinationType: DestinationType
    var mode: String
    var preference: String?
    var avoir: [String]?
    var calculationMode: CalculationMode?
    
    enum DestinationType {
        case regular,monument,pointOfInterest
    }
    
}
