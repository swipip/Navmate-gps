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
    func didDrawRerouting()
    func didSelectMonument()
}
class MapVC: UIViewController {
    
    lazy var mapView: MKMapView = {
        let map = MKMapView()
        map.showsScale = true
        map.showsCompass = true
//        map.layoutMargins = UIEdgeInsets(top: 45, left: 10, bottom: 0, right: 20)
        map.delegate = self
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: mkViews.plain)
        map.register(CustomPlainAV.self, forAnnotationViewWithReuseIdentifier: mkViews.customPlain)
        map.register(MonumentAnnotationView.self, forAnnotationViewWithReuseIdentifier: mkViews.monument)
        map.register(GasAnnotationView.self, forAnnotationViewWithReuseIdentifier: mkViews.gas)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnTheMap(_:)))
        longPress.minimumPressDuration = 0.5
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
        static let gas = "gas"
    }
    
    enum MapNavigationMode {
        case directions, exploration
    }
    
    var mapMode = MapNavigationMode.directions
    
    //MapView Constraints
    var topConstraint = NSLayoutConstraint()
    var bottomConstraint = NSLayoutConstraint()
    var leadingConstraint = NSLayoutConstraint()
    var trailingConstraint = NSLayoutConstraint()
    
    //MARK: - Data
    private var previousLocation: CLLocation?
    private let locator = Locator.shared
    private var destination: CLLocation?
    private var selectedMonument: MKAnnotation?
    private var polyline: MKPolyline?
    
    private var route: Route?
    
    var circleColor = UIColor.red
    
    var delegate: MapVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = K.shared.white
        
        self.addHandle()
        self.addMapView()
        addobservers()
        locator.delegate = self
        locator.checkForAuthorization()
        
        //        let visibleRect = mapView.visibleMapRect
        //        if MKMapRect.contains(visibleRect)
        
    }
    private func addobservers() {
        
        let name = Notification.Name(K.shared.notificationMonumentsMap)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMonuments), name: name, object: nil)
        
    }
    @objc private func didReceiveMonuments(_ notification:Notification) {
        
        if let monuments = notification.userInfo?["monumentsMap"] as? [Monument] {
            
            let point = mapView.convert(mapView.center, toCoordinateFrom: mapView)
            
            let region = MKCoordinateRegion(center: point, latitudinalMeters: 25000, longitudinalMeters: 25000)
            
            mapView.setRegion(region, animated: true)
            
            mapMode = .exploration
            
            self.mapView.removeAnnotations(mapView.annotations)
            
            for monument in monuments {
                
                let annotation = MonumentAnnotation()
                annotation.title = monument.name
                annotation.subtitle = "Monument \(monument.protection)"
                annotation.coordinate = CLLocationCoordinate2D(latitude: monument.latitude, longitude: monument.longitude)
                
                mapView.addAnnotation(annotation)
                
            }
        }
    }
    func setUpDelegate() {
        locator.delegate = self
    }
    func getCenterLocation() -> CLLocation {
        
        let point = mapView.center
        
        let center = mapView.convert(point, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        
        return location
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
    func goToSelectedMonument() {
        
        if let location = selectedMonument {
            
            for annotation in mapView.annotations {
                if annotation.coordinate.latitude == location.coordinate.latitude &&
                    annotation.coordinate.longitude == location.coordinate.longitude{
                    
                }else{
                    mapView.removeAnnotation(annotation)
                }
            }
            
            getRoute(to: location)
            
        }
        
    }
    func getRoute(to annotation: MKAnnotation) {
        
        
        let destination = annotation.coordinate
        
            let request = RouteRequest(destinationName: "Destination",
                                           destination: destination,
                                           destinationType: .regular,
                                           mode: "driving-car",
                                           preference: "shortest",
                                           avoid: ["highways","tollways"],
                                           calculationMode: .initial)
            
            locator.getRoute(request: request)
        
            self.destination = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

    }
    func updateRoute(mode: String,preference: String, avoid: [String],to destination: CLLocation) {
        
        let request = RouteRequest(destinationName: "Destination", destination: destination.coordinate, destinationType: .regular, mode: mode, preference: preference, avoid: avoid, calculationMode: .initial)
        
        
        locator.getRoute(request: request)
        
//        if let location = self.locator.getUserLocation() {
////            locator.getDirections(from: location.coordinate, to: destination.coordinate,mode: mode, preference: preference, avoid: avoid)
//        }
        
        
        
    }
    enum userLocationPrecision {
        case large,medium,close
    }
    func showUserLocation(state: userLocationPrecision) {
        
        var precision:Double = 0
        switch state {
        case .large:
            precision = 5000
        case .medium:
            precision = 500
        case .close:
            precision = 100
        }
        
        if let location = locator.getUserLocation() {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: precision, longitudinalMeters: precision)
            self.mapView.setRegion(region, animated: true)
            self.mapView.showsUserLocation = true
        }

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
            self.mapView.userTrackingMode = .follow
        }

    }
    func animateMapView(on: Bool? = true) {
        
        if on! {
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 26
                self.bottomConstraint.constant = -15
                self.leadingConstraint.constant = 10
                self.trailingConstraint.constant = -10
                self.mapView.layer.cornerRadius = 12
                self.view.layoutIfNeeded()
            }) { (_) in
                
            }
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.topConstraint.constant = 0
                self.bottomConstraint.constant = 0
                self.leadingConstraint.constant = 0
                self.trailingConstraint.constant = 0
                self.mapView.layer.cornerRadius = 0
                self.view.layoutIfNeeded()
            }) { (_) in
                
            }
        }
        

        
    }
    @objc private func didLongPressOnTheMap(_ recognizer:UILongPressGestureRecognizer!) {
        
        if recognizer.state == .began {
            
            mapView.removeAnnotations(mapView.annotations)
            
            let notification = UIImpactFeedbackGenerator(style: .heavy)
            notification.prepare()
            notification.impactOccurred()
            
            let point = recognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let err = error {
                    print(err)
                }else{
                    if let placemark = placemarks?.first {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        annotation.title = placemark.name
                        annotation.subtitle = placemark.locality ?? ""
                        self.mapView.addAnnotation(annotation)
                    }else{
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
            

        }else if recognizer.state == .ended {
            
        }

        
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
        
        self.mapView.removeOverlays(mapView.overlays)
        
        guard !(view.annotation is MKUserLocation) else {return}
        guard let annotation = view.annotation else {return}
        
        switch mapMode {
        case .exploration:
            
            if let selectedMonument = view.annotation {
                self.selectedMonument = selectedMonument
            }
            
            delegate?.didSelectMonument()
        case .directions:
            self.getRoute(to: annotation)
        }
        
        
        
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let polyline = self.polyline {
            self.mapView.addOverlays([polyline])
            self.polyline = nil
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let route = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            route.strokeColor = .systemOrange
            route.lineWidth = 10
            route.miterLimit = 8
            
            
            
            return route
        }else if overlay is MKCircle {
            let circle = MKCircleRenderer(circle: overlay as! MKCircle)
            circle.strokeColor = circleColor
            circle.lineWidth = 2
            return circle
        }
        return MKOverlayRenderer()
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {return nil}
        
        if #available(iOS 11.0, *) {
            let view = mapView.view(for: annotation)
            view?.prepareForDisplay()
        }
        
        if let annotation = annotation as? MonumentAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mkViews.monument, for: annotation) as! MonumentAnnotationView
            
            annotationView.delegate = self
            annotationView.passCoordinates(annotationData: annotation)
            
            return annotationView
        }
        if let annotation = annotation as? GasAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mkViews.gas, for: annotation) as! GasAnnotationView
            
//            annotationView.passCoordinates(annotationData: annotation)
            
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
    func didStartNavigation() {
        
        if let location = locator.getUserLocation() {
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            self.mapView.setRegion(region, animated: true)
            self.mapView.userTrackingMode = .follow
            
        }
        
    }
    func didFindReroutingRoute(route: Route) {
        
        for overlay in mapView.overlays {
            
            mapView.removeOverlay(overlay)
            
        }
        
        delegate?.didDrawRerouting()
        mapView.addOverlay(route.polylines[0])
        mapView.userTrackingMode = .follow
        
//        switch route.summary.destinationType {
//        case .monument:
//            
//            let annotation = MonumentAnnotation()
//            annotation.title = route.summary.destination
//            annotation.coordinate = route.wayPoints[0].coordinate
//            
//            self.mapView.addAnnotation(annotation)
//            
//            break
//        case .regular:
//            break
//        case .pointOfInterest:
//            break
//        }
        
        
    }
    func didFindRoute(polyline: [MKPolyline], summary: Summary) {
        
        
        self.mapView.setVisibleMapRect(polyline[0].boundingMapRect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 300, right: 50), animated: true)
        self.polyline = polyline[0]
        
        if let destination = self.destination {
            self.delegate?.didDrawRoute(summary: summary, destination: destination)
        }
        
    }
    func didChangeAuthorizationStatus() {
        mapView.showsUserLocation = true
        self.showUserLocation(state: .medium)
    }
    #warning("implementation")
    func didFindWayPoints(wayPoints: [CLLocation]) {
//        self.circleColor = .red
//        for waypoint in wayPoints {
//
//            let circle = MKCircle(center: waypoint.coordinate, radius: 30)
//            mapView.addOverlay(circle)
//
//        }
    }
    func didMoveToNextWP(waypointIndex: Int,status: String,location: CLLocation) {
//        self.regionMonitored.text = String("\(waypointIndex) & status: \(status)")

        circleColor = UIColor.blue
        let circle = MKCircle(center: location.coordinate, radius: 30)
        mapView.addOverlay(circle)
        
    }
}
extension MapVC: MonumentAnnotationViewDelegate {
    
    func didPressButton(with detail: MKAnnotation) {
        
        let location = CLLocation(latitude: detail.coordinate.latitude, longitude: detail.coordinate.longitude)
        
        delegate?.didRequestAdditionnalInfo(location: location)
        
    }
    
}

