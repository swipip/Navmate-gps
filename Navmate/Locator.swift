//
//  Locator.swift
//  mapTest2
//
//  Created by Gautier Billard on 15/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
protocol LocatorDelegate: class {
    func didReceiveNewDirectionInstructions(instruction: String)
    func didFindRoute(polyline: [MKPolyline], summary: Summary)
    func didChangeAuthorizationStatus()
    func didFindWayPoints(wayPoints: [CLLocation])
    func didMoveToNextWP(waypointIndex: Int,status: String, location: CLLocation)
    func didFinduserLocation(location: CLLocation)
    func didGetUserSpeed(speed: CLLocationSpeed)
    func didNotFindRoute()
    func didStartNavigation()
}
extension LocatorDelegate {
    func didReceiveNewDirectionInstructions(instruction: String) {}
    func didFindRoute(polyline: [MKPolyline], summary: Summary) {}
    func didChangeAuthorizationStatus() {}
    func didFindWayPoints(wayPoints: [CLLocation]) {}
    func didMoveToNextWP(waypointIndex: Int,status: String, location: CLLocation) {}
    func didFinduserLocation(location: CLLocation) {}
    func didGetUserSpeed(speed: CLLocationSpeed) {}
    func didNotFindRoute() {}
    func didStartNavigation() {}
}
class Locator: NSObject {
    
    let locationManager = CLLocationManager()
    var routeIndex = 0
    var wayPoints:[CLLocation]?
    var steps: [Step]?
    var tripStepIndex = 0
    var monitoredWayPoint: CLLocation?
    var currentWPIndex = 0
    var contains = true
    var nextStepInstruction = ""
    
    var existingWP: CLLocation?
    
    static let shared = Locator()
    weak var delegate: LocatorDelegate?
    
    var route: Route?
    private var durationTracking:Double = 0
    
    let speedNotification = NSNotification.Name(K.shared.notificationSpeed)
    let locationNotification = NSNotification.Name(K.shared.notificationLocation)
    let headingNotification = NSNotification.Name(K.shared.notificationHeading)
    let routeNotification = NSNotification.Name(K.shared.notificationRoute)
    let newStepNotification = NSNotification.Name(K.shared.notificationNewStep)
    let durationTrackingNotification = Notification.Name(K.shared.notificationDurationTracking)
    
    private override init() {
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    private func clearVariableFornewRoute() {
        wayPoints?.removeAll()
        tripStepIndex = 0
        steps?.removeAll()
        currentWPIndex = 0
        locationManager.stopUpdatingLocation()
        self.locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
        routeIndex = 0
    }
    func getTotalTripDuration() -> Double{
        if let duration = self.route?.summary.duration {
            return duration
        }else{
            return 0.0
        }
        
    }
    func startNavigation() {
        
        if let route = self.route {
            
            delegate?.didStartNavigation()
            
            if let duration = self.route?.summary.duration {
                durationTracking = duration
            }
            
            let userInfo = ["steps":route.steps]
            NotificationCenter.default.post(name: routeNotification, object: nil, userInfo: userInfo)
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
        }
        
    }
    func stopNavigation() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    func getUserCurrentSpeed() -> CLLocationSpeed? {
        
        if let speed = locationManager.location?.speed {
            delegate?.didGetUserSpeed(speed: speed)
            return speed
        }
        return nil
    }
    func checkForAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            delegate?.didChangeAuthorizationStatus()
            break
        case .authorizedWhenInUse:
            delegate?.didChangeAuthorizationStatus()
            break
        case .denied:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break

        @unknown default:
            break
        }
        
    }
    func getUserLocation() -> CLLocation? {
        
        let location = locationManager.location
        if let loc = location {
            delegate?.didFinduserLocation(location: loc)
        }
        return location
    }
    func getDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D,mode: String,preference: String? = "shortest", avoid: [String]? = ["highways"]) {

        self.clearVariableFornewRoute()
        
        let routingManager = RoutingManager()
        routingManager.delegate = self
        
        routingManager.getDirections(from: source, to: destination,mode: mode, preference: preference!, avoid: avoid!)
        
    }
    fileprivate func sendDurationUpdateNotification(_ durationToNextWayPoint: Double) {
        durationTracking -= durationToNextWayPoint
        let userInfo = ["duration":durationTracking]
        NotificationCenter.default.post(name: durationTrackingNotification, object: nil, userInfo: userInfo)
    }
    
    private func updateInstructions() {
        
        guard let steps = self.steps else {return}
        guard let wayPoints = self.wayPoints else {return}
        
        if currentWPIndex == wayPoints.count {
            let instruction = "Vous êtes arrivé"
            locationManager.stopUpdatingLocation()
            delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
            
            NotificationCenter.default.post(name: newStepNotification, object: nil)
            
        }
        
        for (i,step) in steps.enumerated() {
            
            let entry = step.wayPoints.first!
            let exit = step.wayPoints.last!
            let dif = exit - entry
            
            let durationToNextWayPoint = step.duration / Double(dif)
                  
            let nextIndex = min(i+1,steps.count-1)
            
            let nextEntry = steps[nextIndex].wayPoints.first!
            let nextExit = steps[nextIndex].wayPoints.last!
            let nextDif = nextExit-nextEntry
            
            switch currentWPIndex {
            case entry:
                if dif == 1 {
                    //entry and exit very close
                    let instruction = "\(step.instruction) then in \(step.distance) \(steps[i+1].instruction) "
                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
                    
                    NotificationCenter.default.post(name: newStepNotification, object: nil)
                    
                    sendDurationUpdateNotification(durationToNextWayPoint)
                    
                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
                    
                }else if entry == 0 {
                    let instruction = "\(step.instruction)"
                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
                    
                    NotificationCenter.default.post(name: newStepNotification, object: nil)
                    
                    sendDurationUpdateNotification(durationToNextWayPoint)
                    
                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
                }else{
                    let instruction = "\(step.instruction)"
                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
                    
                    NotificationCenter.default.post(name: newStepNotification, object: nil)
                    
                    sendDurationUpdateNotification(durationToNextWayPoint)
                    
                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
                }
                currentWPIndex += 1
                self.monitoredWayPoint = wayPoints[currentWPIndex]
                return
            case exit:
                if i <= steps.count - 2 {
                    let instruction =  "\(steps[nextIndex].instruction)"
                    if nextDif == 1 {
                        nextStepInstruction = "\(steps[i+2].instruction)"
                        existingWP = monitoredWayPoint
                        contains = false
                    }
                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
                    
                    NotificationCenter.default.post(name: newStepNotification, object: nil)
                    
                    sendDurationUpdateNotification(durationToNextWayPoint)
                    
                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "exit", location: monitoredWayPoint!)
                    
                    
                }
                if steps.count != 0 {self.steps?.removeFirst()}
                currentWPIndex += 1
                if currentWPIndex >= wayPoints.count-1 {
                    
                }else{
                    self.monitoredWayPoint = wayPoints[currentWPIndex]
                }
                
                return
            default:
                if currentWPIndex > entry && currentWPIndex < exit {
                    let instruction = "In \(step.distance) meters \(steps[i+1].instruction)"
                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
                    
                    NotificationCenter.default.post(name: newStepNotification, object: nil)
                    
                    sendDurationUpdateNotification(durationToNextWayPoint)
                    
                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "default", location: monitoredWayPoint!)
                    currentWPIndex += 1
                    self.monitoredWayPoint = wayPoints[currentWPIndex]
                    return
                }
                break
            }
            
        }
        
    }
    
}
extension Locator: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let speed = getUserCurrentSpeed() {
            delegate?.didGetUserSpeed(speed: speed)
            let userInfo = ["speed":speed]
            NotificationCenter.default.post(name: speedNotification, object: nil, userInfo: userInfo)
            
        }
        
        let userInfo = ["location":locations.last]
        NotificationCenter.default.post(name: locationNotification, object: nil, userInfo: userInfo as! [AnyHashable : CLLocation])

        guard let location = locations.last else {return}
        guard let monitoredWayPoint = self.monitoredWayPoint else {return}

        let region = CLCircularRegion(center: monitoredWayPoint.coordinate, radius: 55, identifier: "")

        if region.contains(location.coordinate){

            updateInstructions()

        }
        if let existingWp = self.existingWP {
            let exitingRegion = CLCircularRegion(center: existingWp.coordinate, radius: 55, identifier: "")

            if exitingRegion.contains(location.coordinate) == false {
                contains = true
                let message = nextStepInstruction
                
                NotificationCenter.default.post(name: newStepNotification, object: nil)
                
                delegate?.didReceiveNewDirectionInstructions(instruction: message)
                self.existingWP = nil
            }
        }

        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
//        guard let wayPoints = self.wayPoints else {return}
//        guard let steps = self.steps else {return}
//
//        locationManager.stopMonitoring(for: region)
//
//        var message = ""
//        for (i,step) in steps.enumerated() {
//            if step.wayPoints.first == currentWPIndex {
//                message = step.instruction
//            }else if step.wayPoints.last == currentWPIndex {
//                message = steps[i+1].instruction
//            }else if step.wayPoints.first! < currentWPIndex && step.wayPoints.last! > currentWPIndex {
//                message = "Prepare to \(steps[i+1].instruction)"
//            }
//        }
//
//        delegate?.didReceiveNewDirectionInstructions(instruction: message)
//
//        NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//
//        currentWPIndex += 1
//        let coordinate = wayPoints[currentWPIndex]
//        let region = CLCircularRegion(center: coordinate.coordinate, radius: 30, identifier: "monitoredWP")
//
//        locationManager.startMonitoring(for: region)
        
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        guard let _ = self.wayPoints else {return}

        
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print(error)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        let userInfo = ["heading":newHeading]
        NotificationCenter.default.post(name: headingNotification, object: nil, userInfo: userInfo as [AnyHashable:CLHeading])
        
    }
}
extension Locator: RoutingManagerDelegate {
    
    func didnotFindRoute() {
        delegate?.didNotFindRoute()
    }
    
    func didFindRoute(route: Route) {
        
        self.route = route
        self.wayPoints = route.wayPoints
        self.steps = route.steps
        
        //        highlightWayPoints()
        
        if let monitoredWayPoint = wayPoints!.first {
            self.monitoredWayPoint = monitoredWayPoint
            #warning("set back to zero")
            self.currentWPIndex = 0
//            let region = CLCircularRegion(center: monitoredWayPoint.coordinate, radius: 30, identifier: "firstWayPoint")
//            locationManager.startMonitoring(for: region)
        }
        
//        for i in 0...10 {
//
//            if let waypoint = wayPoints?[i] {
//                let region = CLCircularRegion(center: waypoint.coordinate, radius: 20, identifier: "\(i)")
//                locationManager.startMonitoring(for: region)
//            }
//
//        }
//        locationManager.startUpdatingLocation()
        
        #warning("test distance filter")
//                locationManager.distanceFilter = 3
        
//        delegate?.didReceiveAllInstructions(steps: route.steps)

        
        delegate?.didFindRoute(polyline: route.polylines, summary: route.summary)
        delegate?.didFindWayPoints(wayPoints: route.wayPoints)
    }
}
