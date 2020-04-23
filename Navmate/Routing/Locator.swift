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

enum CalculationMode {
    case initial,recalculation
}

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
    func didFindReroutingRoute(route: Route)
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
    func didFindReroutingRoute(route: Route) {}
}
class Locator: NSObject {
    
    let locationManager = CLLocationManager()
    var routeIndex = 0
    var wayPoints:[CLLocation]?
    var steps: [Step]?
    var tripStepIndex = 0
    var monitoredWayPoint: CLLocation?
    var currentWPIndex: Int?
    var contains = true
    var nextStepInstruction = ""
    var previousLocation: CLLocation?
    var existingWP: CLLocation?
    
    static let shared = Locator()
    weak var delegate: LocatorDelegate?
    
    var route: Route?
    var currentRequest: RouteRequest?
    private var durationTracking:Double = 0
    var radius = 30.0
    var entered = false
    var left = true
    var currentStep: (index: Int,step: Step)?
    
    let speedNotification = NSNotification.Name(K.shared.notificationSpeed)
    let locationNotification = NSNotification.Name(K.shared.notificationLocation)
    let headingNotification = NSNotification.Name(K.shared.notificationHeading)
    let routeNotification = NSNotification.Name(K.shared.notificationRoute)
    let newStepNotification = NSNotification.Name(K.shared.notificationNewStep)
    let durationTrackingNotification = Notification.Name(K.shared.notificationDurationTracking)
    let distanceNotification = Notification.Name(K.shared.notificationDistance)
    let totalDistanceNotification = Notification.Name(K.shared.notificationTotalDistance)
    
    private var calculationMode: CalculationMode?
    
    private var newRoute: Route?
    
    private override init() {
        super.init()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        
    }
    private func clearVariableFornewRoute() {
        wayPoints?.removeAll()
        tripStepIndex = 0
        steps?.removeAll()
        currentWPIndex = nil
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
    func secondsToHoursMinutesSeconds (seconds : Int) -> (timeString: String,hours:Int,minutes: Int,seconds: Int) {
        
        let time = (hours: seconds / 3600,minutes: (seconds % 3600) / 60,seconds: (seconds % 3600) % 60)
        
        var timeString = ""
        if seconds <= 60{
             timeString = "0\(time.minutes) minute"
        }else if seconds <= 600 {
            timeString = "0\(time.minutes) minutes"
        }else if seconds <= 3600 {
            timeString = "\(time.minutes) minutes"
        }else{
            timeString = "\(time.hours):\(time.minutes) heures"
        }
        
        return (timeString,time.hours,time.minutes,time.seconds)
    }
    func startRerouting() {
        
        guard let newRoute = self.newRoute else {return}
        
        delegate?.didFindReroutingRoute(route: newRoute)
        
        if let duration = self.route?.summary.duration {
            durationTracking = duration
        }
        
        if let monitoredWayPoint = wayPoints!.first {
            self.monitoredWayPoint = monitoredWayPoint
            self.currentWPIndex = 0
        }

        
    }
    func startNavigation() {
        
        if let route = self.route {
            
            delegate?.didStartNavigation()
            
            if let duration = self.route?.summary.duration {
                durationTracking = duration
            }
            
            let userInfo = ["route":route]
            NotificationCenter.default.post(name: routeNotification, object: nil, userInfo: userInfo)
            
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            
            if let monitoredWayPoint = wayPoints!.first {
                self.monitoredWayPoint = monitoredWayPoint
                self.currentWPIndex = 0
            }
            
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
        
        locationManager.startUpdatingLocation()
        
        let location = locationManager.location
        if let loc = location {
            delegate?.didFinduserLocation(location: loc)
        }
        return location
    }
    func getCurrentRouteRequestInfo() -> RouteRequest? {
        if let request = self.currentRequest {
            return request
        }else{
            return nil
        }
    }
    func getRoute(request: RouteRequest) {
        
        self.currentRequest = request
        
        if let location = self.getUserLocation() {
            
            self.calculationMode = request.calculationMode
            
            if calculationMode == .initial {
                self.clearVariableFornewRoute()
            }
            
            let routingManager = RoutingManager()
            routingManager.delegate = self
            
            routingManager.getDirections(from: location.coordinate, to: request.destination,mode: request.mode, preference: request.preference ?? "shortest", avoid: request.avoid ?? ["highways","tollways"])
            
            
        }
    }
    fileprivate func sendDurationUpdateNotification(_ durationToNextWayPoint: Double) {
        durationTracking -= durationToNextWayPoint
        let userInfo = ["duration":durationTracking]
        NotificationCenter.default.post(name: durationTrackingNotification, object: nil, userInfo: userInfo)
    }
    
    fileprivate func sendDistanceUpdateNotification(_ dif: Int, _ step: Step, _ distanceToNextWayPoint: Double) {
        
        guard let currentWPIndex = currentWPIndex else {return}
        
        let portionOfStepDistance = currentWPIndex / dif
        
        let remainingDistance = step.distance - distanceToNextWayPoint * Double(portionOfStepDistance)
        let userInfo = ["distance": remainingDistance]
        NotificationCenter.default.post(name: distanceNotification, object: nil, userInfo: userInfo)
    }
    
//    private func updateInstructions() {
//
//        guard let steps = self.steps else {return}
//        guard let wayPoints = self.wayPoints else {return}
//
//        if currentWPIndex == wayPoints.count {
//            let instruction = "Vous êtes arrivé"
//            locationManager.stopUpdatingLocation()
//            delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//            NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//        }
//
//        for (i,step) in steps.enumerated() {
//
//            let entry = step.wayPoints.first!
//            let exit = step.wayPoints.last!
//            let dif = exit - entry
//
//            let durationToNextWayPoint = step.duration / max(1,Double(dif))
//            let distanceToNextWayPoint = step.distance / max(1,Double(dif))
//
//            let nextIndex = min(i+1,steps.count-1)
//
//            let nextEntry = steps[nextIndex].wayPoints.first!
//            let nextExit = steps[nextIndex].wayPoints.last!
//            let nextDif = nextExit-nextEntry
//
//            switch currentWPIndex {
//            case entry:
//                if dif == 1 {
//                    //entry and exit very close
//                    let instruction = "\(step.instruction) then in \(step.distance) \(steps[i+1].instruction) "
//                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//                    NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//                    sendDurationUpdateNotification(durationToNextWayPoint)
//
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
//
//                }else if entry == 0 {
//                    let instruction = "\(step.instruction)"
//                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//                    NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//                    sendDurationUpdateNotification(durationToNextWayPoint)
//
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
//                }else{
//                    let instruction = "\(step.instruction)"
//                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//                    NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//                    sendDurationUpdateNotification(durationToNextWayPoint)
//
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "enter", location: monitoredWayPoint!)
//                }
//                currentWPIndex += 1
//                self.monitoredWayPoint = wayPoints[currentWPIndex]
//                return
//            case exit:
//                if i <= steps.count - 2 {
//                    let instruction =  "\(steps[nextIndex].instruction)"
//                    if nextDif == 1 {
//                        nextStepInstruction = "\(steps[i+2].instruction)"
//                        existingWP = monitoredWayPoint
//                        contains = false
//                    }
//                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//                    NotificationCenter.default.post(name: newStepNotification, object: nil)
//
//                    sendDurationUpdateNotification(durationToNextWayPoint)
//
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "exit", location: monitoredWayPoint!)
//
//
//                }
//
//                let userInfo = ["totalDistance": steps[max(0,i-1)].distance]
//                NotificationCenter.default.post(name: totalDistanceNotification, object: nil, userInfo: userInfo)
//
//                if steps.count != 0 {self.steps?.removeFirst()}
//                currentWPIndex += 1
//                if currentWPIndex >= wayPoints.count-1 {
//
//                }else{
//                    self.monitoredWayPoint = wayPoints[currentWPIndex]
//                }
//
//                return
//            default:
//                if currentWPIndex > entry && currentWPIndex < exit {
//
////                    sendDistanceUpdateNotification(dif, step, distanceToNextWayPoint)
//
//                    let instruction = "In \(step.distance) meters \(steps[i+1].instruction)"
//                    delegate?.didReceiveNewDirectionInstructions(instruction: instruction)
//
//                    sendDurationUpdateNotification(durationToNextWayPoint)
//
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "default", location: monitoredWayPoint!)
//                    currentWPIndex += 1
//                    self.monitoredWayPoint = wayPoints[currentWPIndex]
//                    return
//                }
//                break
//            }
//
//        }
//
//    }
    
}
extension Locator: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let route = self.route else {return}
        guard let currentWPIndex = currentWPIndex else {return}
        
        let wayPoints = route.wayPoints
        
        if let location = locations.last {
            
            let region = CLCircularRegion(center: wayPoints[currentWPIndex].coordinate, radius: radius, identifier: "")
        
            if region.contains(location.coordinate) {
                //user entering
                if entered == false {
                    print("entered")
                    
                    for (i,step) in route.steps.enumerated() {
                        let wayPointRange = step.wayPoints
                        let enterWP = wayPointRange.first
                        let dif = wayPointRange.last! - wayPointRange.first!
                        print("dif: \(dif)")
                        delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "entered", location: wayPoints[currentWPIndex])
                        
                        if currentWPIndex == enterWP {
                            self.currentStep = (i,step)
                            if currentWPIndex == 0 {
                                //                                self.currentWPIndex! += 1
                            }else{
                                if dif != 1 {
                                    if step.type == 7 || step.type == 8{

                                    }else{
                                        print("entered \(currentWPIndex) \(wayPointRange)")
                                                                           NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
                                    }
                                }
                            }
                        }
                    }
                    
                    entered = true
                    left = false
                }
                
                
            }else{
                // user leaving
                if left == false {
                    print("left \(currentWPIndex)")
                    
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "entered", location: wayPoints[currentWPIndex])
                    
                    for (i,step) in route.steps.enumerated() {
                        let wayPointRange = step.wayPoints
                        let exitWP = wayPointRange.last
                         let dif = wayPointRange.last! - wayPointRange.first!
                        
                        if currentWPIndex == 0 {
//                            print("left\(currentWPIndex) \(wayPointRange)")
//                            NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
                        }
                        if dif == 1 {
                            print("left\(currentWPIndex) \(wayPointRange)")
                            NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
                        }else {
                            if currentWPIndex == exitWP {
                                self.currentStep = (i,route.steps[i+1])
                                
                                print("left\(currentWPIndex) \(wayPointRange)")
                                NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
                                
                                
                                //                            delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "entered", location: wayPoints[currentWPIndex])
                                
                            }
                        }

                    }
                    
                    left = true
                    entered = false
                    self.currentWPIndex! = currentStep!.step.wayPoints.last!
                    print("\(self.currentWPIndex)")
                    delegate?.didMoveToNextWP(waypointIndex: self.currentWPIndex!, status: "entered", location: wayPoints[self.currentWPIndex!])
                }
                
            }
            //on monitoring issue, catch up
//            for (i,waypoint) in wayPoints.enumerated() {
//                let region = CLCircularRegion(center: waypoint.coordinate, radius: radius * 1.1, identifier: "catchUp\(i)")
//                if region.contains(location.coordinate) {
//                    currentWPIndex = i
//                    for (i,step) in route.steps.enumerated() {
//                        let range = step.wayPoints
//                        if currentWPIndex <= range.first! && currentWPIndex >= range.last! {
//                            if let currentIndex = self.currentStep?.index {
//                                self.currentStep = (i,step)
//
//                                let stepGap = currentIndex - currentStep!.index
//
//                                for _ in 0 ..< stepGap {
//                                    NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
//                                }
//
//                            }else{
//
//                            }
//                            return
//                        }
//                    }
//                }
//            }
            //if still not found recalculate
            
        }
                
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForAuthorization()
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
        
        if let calcMode = self.calculationMode {
            switch calcMode {
            case .initial:
                
                self.route = route
                self.wayPoints = route.wayPoints
                self.steps = route.steps
                
                delegate?.didFindWayPoints(wayPoints: route.wayPoints)
                
                #warning("test distance filter")
                locationManager.distanceFilter = 1
                
                delegate?.didFindRoute(polyline: route.polylines, summary: route.summary)
                delegate?.didFindWayPoints(wayPoints: route.wayPoints)
                
            case .recalculation:
                
                self.newRoute = route
                
                let userInfo = ["routeNew":route]
                NotificationCenter.default.post(name: routeNotification, object: nil, userInfo: userInfo)
                
            }
        }
        
        
    }
}
