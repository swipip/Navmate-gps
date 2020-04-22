//
//  AvgMetricsCell.swift
//  Navmate
//
//  Created by Gautier Billard on 22/04/2020.
//  Copyright © 2020 Gautier Billard. All rights reserved.
//

import UIKit

class AvgMetricsCell: UITableViewCell {

    private lazy var thumbNail: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage()
        imageV.contentMode = .scaleAspectFit
        return imageV
    }()
    private lazy var metricName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize)
        label.textColor = K.shared.bluegray
        label.text = "-"
        return label
    }()
    private lazy var metricValue: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: K.shared.cardTitleFontSize,weight: .bold)
        label.textColor = K.shared.bluegray
        label.text = "-"
        label.textAlignment = .right
        return label
    }()
    
    var timer = Timer()
    var totalTime = 0
    var timeElpased = 0
    
    var maxSpeed:Double?
    var avgSpeed: Double?
    var totalDistance: Double?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.addImageView()
        self.addMetricName()
        self.addMetricValueLabel()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    enum CellType {
        case avgSpeed,maxSpeed,duration,distance
    }
    func passData(imageName: String, metricName: String, cellType: CellType) {
        
        self.metricName.text = metricName
        self.thumbNail.image = UIImage(named: imageName)
        
        switch cellType {
        case .maxSpeed:
            self.maxSpeed = 0.0
            let speed = NSNotification.Name(K.shared.notificationSpeed)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: speed, object: nil)
        case .avgSpeed:
            self.avgSpeed = 0.0
            self.totalTime = 1
            self.timeElpased = 1
            let speed = NSNotification.Name(K.shared.notificationSpeed)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: speed, object: nil)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(didUpdateTimeElapsedForAvg), userInfo: nil, repeats: true)
        case .duration:
            self.totalTime = 1
            self.timeElpased = 1
            self.metricValue.text = "00 min"
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
            
        case .distance:
            self.totalDistance = 0.0
            let distance = NSNotification.Name(K.shared.notificationTotalDistance)
            NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification), name: distance, object: nil)
        }
        
    }
    @objc private func didUpdateTimeElapsedForAvg() {
        self.timeElpased += 1
        self.totalTime += 1
    }
    @objc private func didReceiveNotification(_ notification: Notification) {
        
        if let speed = notification.userInfo?["speed"] as? Double {
            if let maxSpeed = self.maxSpeed {
                if maxSpeed < speed * 3.6 {
                    self.maxSpeed = speed * 3.6
                    self.metricValue.text = "\(Int(maxSpeed)) Kmh"
                }
            }
            if let avgSpeed = self.avgSpeed {
                
                self.avgSpeed = (avgSpeed / Double(totalTime)) + (speed * 3.6 * Double(timeElpased) / Double(totalTime))
                
                print("total: \(totalTime) elapsed: \(timeElpased)")
                
                self.metricValue.text = "\(String(format: "%.0f", self.avgSpeed ?? 0)) Kmh"
                
                self.timer.fire()
                
                self.timeElpased = 0
            }
        }
        if let distance = notification.userInfo?["totalDistance"] as? Double {
            
            if let dist = self.totalDistance {
                
                self.totalDistance = dist + distance
                
                if self.totalDistance! > 1000 {
                    let total = self.totalDistance! / 1000
                    let totalString = String(format: "%.1f", total)
                    self.metricValue.text = "\(totalString) Km"
                }else{
                    self.metricValue.text = "\(Int(self.totalDistance!)) m"
                }
                
            }
            
        }
    }
    @objc private func updateTime() {
        self.totalTime += 60
        
        let time = self.secondsToHoursMinutesSeconds(seconds: totalTime)
        
        if self.totalTime <= 600 {
            self.metricValue.text = "0\(time.minutes) min"
        }else if self.totalTime <= 3600 {
            self.metricValue.text = "\(time.minutes) min"
        }else{
            self.metricValue.text = "\(time.hours):\(time.minutes) heures"
        }
    }
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours:Int,minutes: Int,seconds: Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    private func addMetricValueLabel() {
        
        self.addSubview(metricValue)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: -20),
                                         fromView.centerYAnchor.constraint(equalTo: self.metricName.centerYAnchor ,constant: 0)])
        }
        addConstraints(fromView: metricValue, toView: self)
        
    }
    private func addMetricName() {
        
        self.addSubview(metricName)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 35),
                                         fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor ,constant: 0)])
        }
        addConstraints(fromView: metricName, toView: self.thumbNail)
        
    }
    private func addImageView() {
        
        self.addSubview(self.thumbNail)
        
        func addConstraints(fromView: UIView, toView: UIView) {
               
           fromView.translatesAutoresizingMaskIntoConstraints = false
           
            NSLayoutConstraint.activate([fromView.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 25),
                                         fromView.heightAnchor.constraint(equalToConstant: 50),
                                        fromView.widthAnchor.constraint(equalToConstant: 50),
                                        fromView.centerYAnchor.constraint(equalTo: toView.centerYAnchor,constant: 0)])
        }
        addConstraints(fromView: self.thumbNail, toView: self)
        
    }

}
