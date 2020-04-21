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
        view.backgroundColor = .white
        view.addShadow(radius: 5, opacity: 0.5, color: .gray)
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var metricIV: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage()
        imageV.tintColor = UIColor(named: "orange")
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private lazy var metricValue: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 27, weight: .medium)
        label.textColor = UIColor(named: "brown")
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var type: metricCellType?
    var startUpdating = false
    enum metricCellType {
        case speed,location,altitude,course
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.addCard()
        self.addMetricImage()
        self.addLabel()
        
        let speed = NSNotification.Name(K.shared.notificationSpeed)
        let location = NSNotification.Name(K.shared.notificationLocation)
        let heading = NSNotification.Name(K.shared.notificationHeading)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: speed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: location, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: heading, object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didReceiveNotification(notification: NSNotification) {
        
        if startUpdating == true {
            switch self.type {
            case .speed:
                if let speed = notification.userInfo?["speed"] as? Double {
                    let speedString = String(format: "%.2f",speed)
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
    
    func updateType(type: metricCellType) {

//        let metrics = ["speed","marker","mountain","time","journey"]
        
        self.startUpdating = true
        
        self.type = type
        switch self.type {
        case .speed:
            self.metricIV.image = UIImage(named: "speed")
        case .altitude:
            self.metricIV.image = UIImage(named: "altitude")
        case .location:
            self.metricIV.image = UIImage(named: "location")
        case .course:
            self.metricIV.image = UIImage(named: "compass")
        default:
            self.metricIV.image = UIImage(named: "marker")
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
