//
//  RouteQuery.swift
//  Navmate
//
//  Created by Gautier Billard on 18/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation

struct RouteQueryModel: Codable {
    
    var options: AvoidFeatures?
    var alternative_routes: AlternativeRoutes?
    var preference: String
    var coordinates: [[Double]]
}
struct AlternativeRoutes: Codable {
    
    var share_factor: Double
    var target_count: Double
    var weight_factor: Double
    
}
struct AvoidFeatures: Codable {
    
    var avoid_features: [String]
    
}
