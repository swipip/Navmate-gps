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
    let totalTimeNotification = Notification.Name(K.shared.notificationTotalTime)
    let avgSpeedNotification = Notification.Name(K.shared.notificationAvgSpeed)
    
    private var calculationMode: CalculationMode?
    private var newRoute: Route?
    
    private var durationTracking:Double = 1
    private var incrementDurationTracking:Double = 1
    private var distanceTracking: Double = 0
    private var stepDistanceTracking: Double = 0
    private var timeTrackingTimer = Timer()
    private var avgSpeedTimer = Timer()
    private var avgSpeedIncrementTimeTracker:Double = 1
    private var notificationNumber = 0
    private var doNotSendNextInstruction = false
    
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
        entered = false
        left = true
        previousLocation = nil
        notificationNumber = 0
        durationTracking = 1
        incrementDurationTracking = 1
        distanceTracking = 0
        stepDistanceTracking = 0
        timeTrackingTimer.invalidate()
        avgSpeedTimer.invalidate()
        avgSpeedIncrementTimeTracker = 1
        wayPoints?.removeAll()
        tripStepIndex = 0
        steps?.removeAll()
        currentWPIndex = nil
        currentStep = nil
        locationManager.stopUpdatingLocation()
        locationManager.monitoredRegions.forEach({ self.locationManager.stopMonitoring(for: $0) })
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
        if seconds <= 120{
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
    @objc private func incrementTime() {
        incrementDurationTracking += 0.1
    }
    @objc private func incrementTimeForSpeedComputation() {
        avgSpeedIncrementTimeTracker += 1
    }
    func startNavigation() {
        
        timeTrackingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementTime), userInfo: nil, repeats: true)
        avgSpeedTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimeForSpeedComputation), userInfo: nil, repeats: true)
        
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
        clearVariableFornewRoute()
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
}
extension Locator: CLLocationManagerDelegate {
    

    func filterLocation(_ location: CLLocation) -> Bool{
        let age = -location.timestamp.timeIntervalSinceNow
        
        if age > 10{
            return false
        }
        
        if location.horizontalAccuracy < 0{
            return false
        }
        
        if location.horizontalAccuracy > 100{
            return false
        }
//        if location.verticalAccuracy < 0{
//            return false
//        }
//        if location.verticalAccuracy > 100 {
//            return false
//        }
        
        return true
        
    }
    fileprivate func sendDistanceAndLocationUpdate(_ suitableForSpeedAndAltitude: Bool, _ location: CLLocation) {
        if suitableForSpeedAndAltitude {
            
            let userInfo = ["location":location]
            NotificationCenter.default.post(name: locationNotification, object: nil, userInfo: userInfo)
            
            if let previous = previousLocation {
                
                if let _ = currentStep?.step.distance {
                    
                    let distance = stepDistanceTracking - distanceTracking
                    
                    var userInfo = ["distance":distance]
                    NotificationCenter.default.post(name: distanceNotification, object: nil, userInfo: userInfo)
                    userInfo = ["totalDistance":distanceTracking]
                    NotificationCenter.default.post(name: totalDistanceNotification, object: nil, userInfo: userInfo)
                    
                }
                
                let distance = previous.distance(from: location)
                distanceTracking += distance
            }
            previousLocation = location
        }
    }
    
    fileprivate func sendTimeUpdate(_ suitableForSpeedAndAltitude: Bool, _ location: CLLocation) {
        if suitableForSpeedAndAltitude {
            let timeTrackingRegion = CLCircularRegion(center: location.coordinate, radius: 2, identifier: "timeTrack")
            
            let userIf = ["totalTime":avgSpeedIncrementTimeTracker]
            NotificationCenter.default.post(name: totalTimeNotification, object: nil, userInfo: userIf)
            
            if let previousLocation = self.previousLocation {
                if timeTrackingRegion.contains(previousLocation.coordinate) {
                    timeTrackingTimer.invalidate()
                }else{
                    timeTrackingTimer.fire()
                    
                    if let timeTotal = self.route?.summary.duration {
//                        print("duration: \(incrementDurationTracking)")
                        let timeleft = max(0,timeTotal - incrementDurationTracking)
                        let userInfo = ["duration":timeleft]
                        NotificationCenter.default.post(name: durationTrackingNotification, object: nil, userInfo: userInfo)
                    }
                    
                    
                }
            }
            
            
        }
    }
    
    fileprivate func sendAvgSpeedUpdate() {
        let avgSpeed = distanceTracking / avgSpeedIncrementTimeTracker
//        print("\(distanceTracking) / \(avgSpeedIncrementTimeTracker)")
        let userInfo = ["avgSpeed":avgSpeed]
        NotificationCenter.default.post(name: avgSpeedNotification, object: nil, userInfo: userInfo)
        
    }
    private func sendNotification() {
        
        if notificationNumber <= currentStep!.index + 1{
            NotificationCenter.default.post(name: newStepNotification, object: nil, userInfo: nil)
            notificationNumber += 1
        }else{
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let route = self.route else {return}
        guard let currentWPIndex = currentWPIndex else {return}
        
        let wayPoints = route.wayPoints
        
        if let location = locations.last {
            
            let suitableForSpeedAndAltitude = filterLocation(location)
            
            sendTimeUpdate(suitableForSpeedAndAltitude, location)
            
            sendDistanceAndLocationUpdate(suitableForSpeedAndAltitude, location)
            
            sendAvgSpeedUpdate()
            
            if suitableForSpeedAndAltitude {
                let userInfo = ["speed":location.speed]
                NotificationCenter.default.post(name: speedNotification, object: nil, userInfo: userInfo)
            }
            
            let region = CLCircularRegion(center: wayPoints[currentWPIndex].coordinate, radius: radius, identifier: "")
        
            if region.contains(location.coordinate) {
                //user entering
                if entered == false {
                    
                    
                    for (i,step) in route.steps.enumerated() {
                        let wayPointRange = step.wayPoints
                        let enterWP = wayPointRange.first
                        let dif = wayPointRange.last! - wayPointRange.first!
                        
                        delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "entered", location: wayPoints[currentWPIndex])
                        
                        if currentWPIndex == enterWP {
                            self.currentStep = (i,step)
                            stepDistanceTracking += currentStep!.step.distance
                            if currentWPIndex == 0 {
                                //                                self.currentWPIndex! += 1
                            }else{
                                if dif != 1 {
                                    if step.type == 7 || step.type == 8{
                                        
                                        let previousWP = steps?[max(0,i-1)].wayPoints.first
                                        if previousWP == 0 {
                                            sendNotification()
                                        }
                                        
                                    }else{
                                        if doNotSendNextInstruction{
                                            
                                        }else{
                                           
                                            let maxIndex = route.steps.count-1
                                            if let waypoints = steps?[min(maxIndex,i+1)].wayPoints {
                                                let nextDif = waypoints.last! - waypoints.first!
                                                if nextDif != 1 && dif == 1{
                                                
                                                    sendNotification()
                                                }else{
                                                
                                                    let previousWP = steps?[max(0,i-1)].wayPoints.first
                                                    if previousWP == 0 {
                                                        sendNotification()
                                                    }
                                                    
                                                }
                                            }else{
                                                sendNotification()
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    doNotSendNextInstruction = false
                    contains = true
                    entered = true
                    left = false
                }
                
                
            }else{
                // user leaving
                
                if left == false {
                    
                    
//                    delegate?.didMoveToNextWP(waypointIndex: currentWPIndex, status: "entered", location: wayPoints[currentWPIndex])
                    
                    for (i,step) in route.steps.enumerated() {
                        let wayPointRange = step.wayPoints
                        let exitWP = wayPointRange.last
                        let dif = wayPointRange.last! - wayPointRange.first!
                        
                        if currentWPIndex == exitWP {
                            if contains == true{
//                                contains = false
                            
                                self.currentStep = (i,route.steps[i+1])
                                
                                sendNotification()
                                break
                            }
                        }else{
                            if dif == 1 && currentWPIndex == wayPointRange.first{
                                
                                if let waypoints = steps?[i+1].wayPoints {
                                    let nextDif = waypoints.last! - waypoints.first!
                                    if nextDif != 1 {
                                        doNotSendNextInstruction = true
                                    }
                                }
                                
                                sendNotification()
                                break
                            }
                        }

                    }
                    
                    left = true
                    entered = false
                    self.currentWPIndex! = currentStep!.step.wayPoints.last!
                   
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
