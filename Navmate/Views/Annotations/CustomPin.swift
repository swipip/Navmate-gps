//
//  CustomPin.swift
//  Navmate
//
//  Created by Gautier Billard on 12/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation

import MapKit

class CustomPin: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var image: UIImage = UIImage(named: "pin")!

    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        //self.image
        super.init()
    }
}
