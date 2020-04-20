//
//  MapVC.swift
//  Navmate
//
//  Created by Gautier Billard on 12/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import MapKit
protocol MapVCDelegate {
    func didDrawRoute(summary: Summary, destination: CLLocation)
    func didRequestAdditionnalInfo(location: CLLocation)
}
class MapVC: UIViewController {
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsScale = true
        map.showsCompass = true
        map.delegate = self
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: mkViews.plain)
        map.register(CustomPlainAV.self, forAnnotationViewWithReuseIdentifier: mkViews.customPlain)
        map.register(MonumentAnnotationView.self, forAnnotationViewWithReuseIdentifier: mkViews.monument)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnTheMap(_:)))
        longPress.minimumPressDuration = 1
        map.addGestureRecognizer(longPress)
        
        return map
    }()
    private lazy var pin: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(named: "pin")
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private lazy var handle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.backgroundColor = .systemGray4
        return view
    }()
    struct mkViews {
        static let plain = "plain"
        static let customPlain = "customPlain"
        static let monument = "monument"
    }
    //MapView Constraints
    var topConstraint = NSLayoutConstraint()
    var bottomConstraint = NSLayoutConstraint()
    var leadingConstraint = NSLayoutConstraint()
    var trailingConstraint = NSLayoutConstraint()
    
    //MARK: - Data
    private var previousLocation: CLLocation?
    private let locator = Locator.shared
    private var destination: CLLocation?
    
    var delegate: MapVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.addHandle()
        self.addMapView()
        
        locator.delegate = self
        locator.checkForAuthorization()
        
        //        let visibleRect = mapView.visibleMapRect
        //        if MKMapRect.contains(visibleRect)
        
    }
    private func addHandle() {
        self.view.addSubview(handle)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0),
                                        fromView.widthAnchor.constraint(equalToConstant: 100),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.heightAnchor.constraint(equalToConstant: 6)])
        }
        addConstraints(fromView: handle, toView: self.view)
    }
    func getRoute(to placeMark: MKPlacemark) {
        
        if let location = locator.getUserLocation(), let destination = placeMark.location?.coordinate {
            locator.getDirections(from: location.coordinate, to: destination, mode: "driving-car")
            self.destination = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        }
        
    }
    func updateRoute(mode: String,preference: String, avoid: [String],to destination: CLLocation) {
        
        if let location = self.locator.getUserLocation() {
            locator.getDirections(from: location.coordinate, to: destination.coordinate,mode: mode, preference: preference, avoid: avoid)
        }
        
        
        
    }
    func showUserLocation() {
        if let location = locator.getUserLocation() {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            self.mapView.setRegion(region, animated: true)
            self.mapView.showsUserLocation = true
        }

    }
    func getCenterLocation() -> CLLocation{
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
    private func addPin() {
        
        self.view.addSubview(pin)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.centerXAnchor.constraint(equalTo: toView.centerXAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 40),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.widthAnchor.constraint(equalToConstant: 40)])
        }
        addConstraints(fromView: pin, toView: self.view)
        
    }
    private func addMapView() {
        
        self.view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        topConstraint = NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        bottomConstraint = NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        leadingConstraint = NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        trailingConstraint = NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        
        self.view.addConstraints([topConstraint,bottomConstraint,leadingConstraint,trailingConstraint])
        
    }
    func centerOnUserLocation() {
        
        if let location = locator.getUserLocation() {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
            self.mapView.setRegion(region, animated: true)
            self.mapView.userTrackingMode = .followWithHeading
        }

    }
    func animateMapView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.topConstraint.constant = 26
            self.bottomConstraint.constant = -15
            self.leadingConstraint.constant = 10
            self.trailingConstraint.constant = -10
            self.mapView.layer.cornerRadius = 12
            self.view.layoutIfNeeded()
        }) { (_) in
            
        }
        
    }
    @objc private func didLongPressOnTheMap(_ recognizer:UILongPressGestureRecognizer!) {
        
//        let point = recognizer.location(in: mapView)
//        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//
//        updatePosition(with: location, name: "")
//
//        getAddress(with: location)
//
        
        
    }
    func setPinUsingMKPlacemark(location: CLLocationCoordinate2D,name: String) {
        
       let pin = MKPlacemark(coordinate: location)
       let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)

       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotation(pin)
    }
}
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let destination = view.annotation?.coordinate {
            let placemark = MKPlacemark(coordinate: destination)
            self.getRoute(to: placemark)
        }
        
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
       
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let route = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            route.strokeColor = .systemOrange
            route.lineWidth = 10
            route.miterLimit = 8
            return route
        }
        return MKOverlayRenderer()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        if let annotation = annotation as? MonumentAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mkViews.monument, for: annotation) as! MonumentAnnotationView
            
            annotationView.delegate = self
            annotationView.passCoordinates(annotationData: annotation)
            
            return annotationView
        }
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mkViews.customPlain, for: annotation) as? CustomPlainAV {
//            annotationView.image = UIImage(named: "pin")
//            annotationView.centerOffset = CGPoint(x: 0, y: -annotationView.image!.size.height / 2)
//            annotationView.canShowCallout = true
            
            return annotationView
        }
        return nil
    }

}
extension MapVC: LocatorDelegate {
    
    func didNotFindRoute() {
        let alert = UIAlertController(title: "Ouuups", message: "Navmate n'a pas réussi à trouver de route pour ce lieu", preferredStyle: .alert)
        let action = UIAlertAction(title: "Continuer", style: .default) { (action) in
            alert.dismiss(animated: true) {
                
            }
        }
        alert.addAction(action)
       
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func didGetUserSpeed(speed: CLLocationSpeed) {
        let kmh = speed * 60 * 60 / 1000
//        speedlabel.text = String(kmh)
    }
    
    func didFinduserLocation(location: CLLocation) {
//        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(region, animated: false)
    }
    
    func didFindRoute(polyline: [MKPolyline], summary: Summary) {
//        mapView.userTrackingMode = .followWithHeading
        mapView.setVisibleMapRect(polyline[0].boundingMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 300, right: 40), animated: true)
        mapView.addOverlays([polyline[0]])
        
        if let destination = self.destination {
            delegate?.didDrawRoute(summary: summary, destination: destination)
        }
        
    }
    func didReceiveNewDirectionInstructions(instruction: String) {
//        label.text = instruction
    }
    func didChangeAuthorizationStatus() {
        mapView.showsUserLocation = true
        self.showUserLocation()
    }
    #warning("implementation")
    func didFindWayPoints(wayPoints: [CLLocation]) {
//        for waypoint in wayPoints {
//
//            let circle = MKCircle(center: waypoint.coordinate, radius: 20)
//            mapView.addOverlay(circle)
//
//        }
    }
    func didMoveToNextWP(waypointIndex: Int,status: String,location: CLLocation) {
//        self.regionMonitored.text = String("\(waypointIndex) & status: \(status)")

//        let circle = MKCircle(center: location.coordinate, radius: 50)
//        mapView.addOverlay(circle)
        
    }
}
extension MapVC: MonumentAnnotationViewDelegate {
    
    func didPressButton(with detail: MKAnnotation) {
        
        let location = CLLocation(latitude: detail.coordinate.latitude, longitude: detail.coordinate.longitude)
        
        delegate?.didRequestAdditionnalInfo(location: location)
        
    }
    
}
