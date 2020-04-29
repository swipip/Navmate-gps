//
//  MonumentAnnotationView.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import MapKit

protocol MonumentAnnotationViewDelegate {
    func didPressButton(with detail: MKAnnotation)
}

class MonumentAnnotationView: MKAnnotationView {
    
    var annotationData: MKAnnotation?
    
    var delegate: MonumentAnnotationViewDelegate?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.image = UIImage(named: "monumentPin")
        self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
        self.canShowCallout = true
        
        let button = AnnotationButton(type: .infoDark)
        button.annotation = annotation
        button.addTarget(self, action: #selector(callOUtInfoButtonPressed(_:)), for: .touchUpInside)
        self.rightCalloutAccessoryView = button
        
    }
    
    func passCoordinates(annotationData: MKAnnotation) {
        self.annotationData = annotationData
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func callOUtInfoButtonPressed(_ sender:UIButton!) {
        guard let _ = sender as? AnnotationButton else {return}
        
        if let annotation = annotationData {
            delegate?.didPressButton(with: annotation)
        }
        
    }
    
}
class AnnotationButton: UIButton {
    var annotation: MKAnnotation? = nil
}
