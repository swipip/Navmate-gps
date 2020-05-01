//
//  GasAnnotationView.swift
//  Navmate
//
//  Created by Gautier Billard on 29/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import MapKit

class GasAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.image = UIImage(named: "gasPin")
        self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
        self.canShowCallout = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
