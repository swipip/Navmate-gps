//
//  NavigationMetricsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 20/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit
import CoreLocation

class NavigationMetricsCell: UICollectionViewCell {
    
    private lazy var cardBG: UIView = {
        let view = UIView()
        view.backgroundColor = K.shared.white
        view.addShadow(radius: 5, opacity: 0.2, color: K.shared.shadow!)
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var metricIV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage()
        imageV.tintColor = UIColor(named: "orange")
        imageV.contentMode = .scaleAspectFill
        return imageV
    }()
    private lazy var metricValue: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        label.textColor = K.shared.blueGrayFont
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var type: metricCellType?
    var startUpdating = false
    enum metricCellType {
        case speed,location,altitude,course,timeLeft
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = K.shared.white
        self.addCard()
        self.addMetricImage()
        self.addLabel()
        
        let speed = NSNotification.Name(K.shared.notificationSpeed)
        let location = NSNotification.Name(K.shared.notificationLocation)
        let heading = NSNotification.Name(K.shared.notificationHeading)
        let duration = NSNotification.Name(K.shared.notificationDurationTracking)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: speed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: location, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: heading, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: duration, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    fileprivate func getTimeString(_ duration: Double) {
        let time = secondsToHoursMinutesSeconds(seconds: Int(duration))
        let minutes = time.minutes
        var minutesString = ""
        if minutes < 10 {
            minutesString = "0\(minutes)"
        }else{
            minutesString = "\(minutes)"
        }
        if time.hours < 1 {
            if minutes == 1 {
                self.metricValue.text = "\(minutesString) minute"
            }else{
                self.metricValue.text = "\(minutesString) minutes"
            }
        }else{
            self.metricValue.text = "\(time.hours):\(minutesString) heures"
        }
    }
    
    @objc private func didReceiveNotification(notification: NSNotification) {
        
        if startUpdating == true {
            switch self.type {
            case .speed:
                if let speed = notification.userInfo?["speed"] as? Double {
                    let kmhSpeed = speed * 3.6
                    let speedString = String(Int(kmhSpeed))
                    self.metricValue.text = "\(speedString) Kmh"
                }
            case .altitude:
                
                if let location = notification.userInfo?["location"] as? CLLocation {
                 
                    let altitude = location.altitude
                    let altitudeString = String(format: "%.2f",altitude)
                    
                    self.metricValue.text = "\(altitudeString) m"
                    
                }
            case .course:
                if let heading = notification.userInfo?["heading"] as? CLHeading {
                 
                    var quadrant = ""
                    
//                    let quadrantVar = heading.magneticHeading / 4
                    
                    if heading.magneticHeading >= 315 || heading.magneticHeading <= 45 {
                        quadrant = "N"
                    }else if heading.magneticHeading > 45 && heading.magneticHeading <= 135 {
                        quadrant = "E"
                    }else if heading.magneticHeading > 135 && heading.magneticHeading <= 225 {
                        quadrant = "S"
                    }else{
                        quadrant = "W"
                    }
                    
                    let courseString = String(format: "%.2f",heading.magneticHeading)
                    self.metricValue.text = "\(courseString)° \(quadrant)"
                    
                }
            case .timeLeft:
                if let duration = notification.userInfo?["duration"] as? Double {
                 
                    getTimeString(duration)
                    
                    
                }
            default:
                if let location = notification.userInfo?["location"] as? CLLocation {
                    
                    let latitude = String(format: "%5f",location.coordinate.latitude)
                    let longitude = location.coordinate.longitude
                    
                    let estWest = longitude > 0 ? "E" : "W"
                    
                    let longitudeString = String(format: "%.5f",location.coordinate.longitude)
                    
                    self.metricValue.text = "\(latitude)N \(longitudeString)\(estWest)"
                }
            }
        }
        
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours:Int,minutes: Int,seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    func updateType(type: metricCellType) {
        
        self.type = type
        
        let metricsImageNames = [metricCellType.speed:"speed",
                                 metricCellType.altitude:"altitude",
                                 metricCellType.location:"location",
                                 metricCellType.course:"compass",
                                 metricCellType.timeLeft:"time",]
        
        self.startUpdating = true
        
        if let name = metricsImageNames[type] {
            if traitCollection.userInterfaceStyle == .dark {
                let imageName = name + "White"
                self.metricIV.image = UIImage(named: imageName)
            }else{
                self.metricIV.image = UIImage(named: name)
            }
           
        }
        
        
        
    }
    private func addLabel() {
        self.addSubview(metricValue)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.leadingAnchor.constraint(equalTo: metricIV.trailingAnchor, constant: 10),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0)])
        }
        addConstraints(fromView: metricValue, toView: self.cardBG)
    }
    private func addMetricImage() {
        
        self.addSubview(metricIV)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 10),
                                        fromView.widthAnchor.constraint(equalToConstant: 55),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor, constant: 0),
                                        fromView.heightAnchor.constraint(equalToConstant: 55)])
        }
        addConstraints(fromView: metricIV, toView: self.cardBG)
        
    }
    private func addCard() {
        self.addSubview(cardBG)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
           NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 20),
                                        fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                        fromView.topAnchor.constraint(equalTo: toView.topAnchor, constant: 10),
                                        fromView.bottomAnchor.constraint(equalTo: toView.bottomAnchor,constant: -10)])
        }
        addConstraints(fromView: cardBG, toView: self)
    }
    
    
}
